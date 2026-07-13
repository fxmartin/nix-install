#!/usr/bin/env python3
"""Network exposure and bearer-token policy for the health API."""

from __future__ import annotations

import hmac
import ipaddress


def normalize_bind_host(host: str) -> str:
    """Normalize bracketed IPv6 notation for use as a socket bind address."""
    return host.strip().removeprefix("[").removesuffix("]")


def is_loopback_host(host: str) -> bool:
    """Return whether a configured bind host is unambiguously loopback-only."""
    normalized_host = normalize_bind_host(host).lower()
    if normalized_host == "localhost":
        return True

    try:
        return ipaddress.ip_address(normalized_host).is_loopback
    except ValueError:
        return False


def validate_network_config(host: str, token: str) -> None:
    """Reject remote exposure unless bearer-token authentication is configured."""
    if not is_loopback_host(host) and not token:
        raise ValueError(
            "HEALTH_API_TOKEN is required when HEALTH_API_HOST is not loopback"
        )


def is_authorized(configured_token: str, authorization_header: str) -> bool:
    """Validate an HTTP bearer header against the configured token."""
    if not configured_token:
        return True

    scheme, separator, supplied_token = authorization_header.partition(" ")
    return (
        scheme == "Bearer"
        and bool(separator)
        and hmac.compare_digest(supplied_token, configured_token)
    )
