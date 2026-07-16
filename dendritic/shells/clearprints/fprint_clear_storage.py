#! /usr/bin/python3

import gi
gi.require_version('FPrint', '2.0')
from gi.repository import FPrint

ctx = FPrint.Context()

print("Looking for fingerprint devices.")

devices = ctx.get_devices()

for dev in devices:
    print(dev)
    print(dev.get_driver())
    print(dev.props.device_id);

    dev.open_sync()

    dev.clear_storage_sync()
    print("All prints deleted.")

    dev.close_sync()

if devices:
    print("All prints on all devices deleted.")
else:
    print("No devices found.")
