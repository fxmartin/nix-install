#!/usr/bin/env python3
# ABOUTME: Unit tests for health-api metrics hardware metadata parsing
# ABOUTME: Verifies /metrics reports real Apple Silicon core counts

import importlib.util
import json
import pathlib
import unittest
from unittest import mock


REPO_ROOT = pathlib.Path(__file__).resolve().parents[1]
HEALTH_API_PATH = REPO_ROOT / "scripts" / "health-api.py"


def load_health_api():
    spec = importlib.util.spec_from_file_location("health_api", HEALTH_API_PATH)
    module = importlib.util.module_from_spec(spec)
    assert spec.loader is not None
    spec.loader.exec_module(module)
    return module


class HealthApiHardwareTests(unittest.TestCase):
    def setUp(self):
        self.health_api = load_health_api()

    def test_parse_cpu_core_info_from_system_profiler_json(self):
        hardware_json = {
            "SPHardwareDataType": [{
                "chip_type": "Apple M3 Max",
                "number_processors": "proc 16:12:4:0",
            }]
        }

        self.assertEqual(
            self.health_api._parse_cpu_core_info(hardware_json),
            {
                "name": "Apple M3 Max",
                "cores": 16,
                "p_cores": 12,
                "e_cores": 4,
            },
        )

    def test_parse_gpu_core_info_from_system_profiler_json(self):
        displays_json = {
            "SPDisplaysDataType": [{
                "sppci_device_type": "spdisplays_gpu",
                "sppci_cores": "40",
            }]
        }

        self.assertEqual(
            self.health_api._parse_gpu_core_info(displays_json),
            {"gpu_cores": 40},
        )

    def test_parse_hardware_info_falls_back_for_missing_core_data(self):
        self.assertEqual(self.health_api._parse_cpu_core_info({}), {})
        self.assertEqual(
            self.health_api._parse_cpu_core_info({
                "SPHardwareDataType": [{
                    "chip_type": "Apple M3 Max",
                    "number_processors": "unexpected",
                }]
            }),
            {"name": "Apple M3 Max"},
        )
        self.assertEqual(self.health_api._parse_gpu_core_info({}), {})
        self.assertEqual(
            self.health_api._parse_gpu_core_info({
                "SPDisplaysDataType": [{"sppci_cores": "unknown"}]
            }),
            {},
        )

    def test_probe_system_metrics_uses_cached_hardware_info(self):
        sample = {
            "timestamp": "2026-04-24T18:25:19.366106+00:00",
            "ecpu_usage": [1969, 0.257],
            "pcpu_usage": [1804, 0.049],
            "gpu_usage": [429, 0.038],
            "memory": {
                "ram_total": 48 * 1024 ** 3,
                "ram_usage": 32 * 1024 ** 3,
                "swap_total": 1024 ** 3,
                "swap_usage": int(0.3 * 1024 ** 3),
            },
            "temp": {"cpu_temp_avg": 37.6, "gpu_temp_avg": 46.9},
            "cpu_power": 1.5,
            "gpu_power": 0.1,
            "ane_power": 0.0,
            "ram_power": 0.8,
            "sys_power": 21.6,
            "all_power": 1.6,
        }
        completed = mock.Mock(returncode=0, stdout=json.dumps(sample), stderr="")

        with mock.patch.object(self.health_api.os.path, "isfile", return_value=True), \
                mock.patch.object(self.health_api.subprocess, "run", return_value=completed), \
                mock.patch.object(self.health_api, "_top_cpu_processes", return_value=[]), \
                mock.patch.object(
                    self.health_api,
                    "get_hardware_info",
                    return_value={
                        "name": "Apple M3 Max",
                        "cores": 16,
                        "e_cores": 4,
                        "p_cores": 12,
                        "gpu_cores": 40,
                    },
                ):
            metrics = self.health_api._probe_system_metrics()

        self.assertIsNotNone(metrics)
        self.assertEqual(
            metrics["system"],
            {
                "name": "Apple M3 Max",
                "cores": 16,
                "e_cores": 4,
                "p_cores": 12,
                "gpu_cores": 40,
            },
        )

    def test_core_usage_from_samples_calculates_per_core_delta(self):
        previous = [
            (100, 50, 850, 0),
            (200, 100, 700, 0),
        ]
        current = [
            (130, 70, 900, 0),
            (260, 130, 710, 0),
        ]

        usage = self.health_api._core_usage_from_samples(previous, current)

        self.assertEqual(usage["cores"][0], {
            "id": 0,
            "active_percent": 50.0,
            "user_percent": 30.0,
            "system_percent": 20.0,
        })
        self.assertEqual(usage["cores"][1], {
            "id": 1,
            "active_percent": 90.0,
            "user_percent": 60.0,
            "system_percent": 30.0,
        })
        self.assertEqual(usage["user_percent"], 45.0)
        self.assertEqual(usage["system_percent"], 25.0)
        self.assertEqual(usage["idle_percent"], 30.0)

    def test_core_usage_from_samples_handles_first_sample(self):
        usage = self.health_api._core_usage_from_samples(None, [(100, 50, 850, 0)])

        self.assertEqual(usage["cores"], [{
            "id": 0,
            "active_percent": 0.0,
            "user_percent": 0.0,
            "system_percent": 0.0,
        }])
        self.assertEqual(usage["user_percent"], 0.0)
        self.assertEqual(usage["system_percent"], 0.0)
        self.assertEqual(usage["idle_percent"], 0.0)

    def test_probe_fast_metrics_includes_external_telemetry_fields(self):
        self.health_api._last_core_cpu_sample = [(100, 50, 850, 0)]

        with mock.patch.object(self.health_api, "_parse_vm_stat", return_value={"total_gb": 48.0}), \
                mock.patch.object(self.health_api, "_parse_swap_usage", return_value={"swap_used_gb": 0.3}), \
                mock.patch.object(self.health_api, "_sample_core_cpu_times", return_value=[(130, 70, 900, 0)]), \
                mock.patch.object(self.health_api, "_fast_cpu_usage_percent", return_value=42.0), \
                mock.patch.object(self.health_api, "_load_average", return_value=[1.0, 2.0, 3.0]), \
                mock.patch.object(self.health_api, "_top_cpu_processes", return_value=[]), \
                mock.patch.object(self.health_api.time, "monotonic", return_value=123.4):
            metrics = self.health_api._probe_fast_metrics()

        self.assertEqual(metrics["cpu"]["usage_percent"], 50.0)
        self.assertEqual(metrics["cpu"]["cores"][0]["active_percent"], 50.0)
        self.assertEqual(metrics["system"]["load_average"], [1.0, 2.0, 3.0])
        self.assertEqual(metrics["system"]["uptime_seconds"], 123)
        self.assertEqual(metrics["memory"]["swap_used_gb"], 0.3)


if __name__ == "__main__":
    unittest.main()
