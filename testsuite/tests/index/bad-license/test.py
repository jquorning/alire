"""
Test that invalid licenses are rejected
"""

from drivers.alr import run_alr
from drivers.asserts import assert_match


p = run_alr('show', 'hello_world',
            complain_on_error=False, debug=False, quiet=True)
assert_match(
    'ERROR: Loading crate .*hello_world.toml: general: licenses: unknown license: \'Invalid license ID\'\n'
    'ERROR: alr show unsuccessful\n',
    p.out)

print('SUCCESS')
