{ ... }:

{
  config = {
    # Only show guides for current scope
    indent.enabled = false;
    scope.enabled = true;

    # Values are in ms
    animate.duration = {
      step = 25;
    };
  };
}
