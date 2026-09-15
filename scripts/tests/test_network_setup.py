import importlib.util
import unittest
from pathlib import Path


SCRIPT_PATH = Path(__file__).parents[1] / "network-setup.py"
SPEC = importlib.util.spec_from_file_location("network_setup", SCRIPT_PATH)
if SPEC is None or SPEC.loader is None:
    raise RuntimeError(f"Unable to load {SCRIPT_PATH}")
network_setup = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(network_setup)


class NetworkBusinessUnitNameTests(unittest.TestCase):
    def test_maps_business_unit_labels_to_existing_network_names(self):
        self.assertEqual(network_setup.network_business_unit_name("Central Digital"), "hq")
        self.assertEqual(network_setup.network_business_unit_name("Technology Services"), "cjse")

    def test_normalises_business_units_that_already_match_network_names(self):
        self.assertEqual(network_setup.network_business_unit_name("LAA"), "laa")
        self.assertEqual(network_setup.network_business_unit_name("Platforms"), "platforms")


if __name__ == "__main__":
    unittest.main()