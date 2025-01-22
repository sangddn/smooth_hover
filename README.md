# Smooth Hover

A Flutter package that provides beautiful, physics-based hover effects and tooltips for your widgets. It creates smooth, animated hover states with customizable ink effects and tooltips.

![Example](https://raw.githubusercontent.com/sangddn/smooth_hover/main/images/example.gif)

## Features

- 🎨 Smooth, physics-based hover animations
- 💫 Customizable ink effects with decorations
- 🎯 Smart tooltips with configurable delays and styles
- 🔄 Built-in focus and press state handling
- 🎮 Customizable mouse cursor behavior
- ⚡ Efficient hover state management

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  smooth_hover: ^0.0.1
```

## Usage

1. Wrap your app or a section of your UI with `SmoothHoverScope`:

```dart
SmoothHoverScope(
  child: YourWidget(),
)
```

2. Use `SmoothHover` to add hover effects to any widget:

```dart
SmoothHover(
  inkDecoration: BoxDecoration(
    color: Colors.grey.withOpacity(0.1),
    borderRadius: BorderRadius.circular(16.0),
  ),
  tooltipText: 'Hello World',
  child: YourWidget(),
)
```

## Example

Here's a simple example showing how to create a hoverable container with a tooltip:

```dart
SmoothHover(
  inkDecoration: BoxDecoration(
    color: const Color.fromARGB(124, 227, 227, 227),
    borderRadius: BorderRadius.circular(16.0),
  ),
  tooltipText: 'Hello World',
  child: Container(
    width: 300,
    height: 80,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16.0),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 8,
          blurStyle: BlurStyle.outer,
        ),
      ],
    ),
    child: Center(
      child: Text('Hover me!'),
    ),
  ),
)
```

## Customization

### Ink Effect

Customize the hover ink effect using the `inkDecoration` and `inkPhysics` parameters:

```dart
SmoothHover(
  inkDecoration: BoxDecoration(
    color: Colors.blue.withOpacity(0.1),
    borderRadius: BorderRadius.circular(8),
  ),
  inkPhysics: Physics(
    // Custom physics parameters
  ),
  child: YourWidget(),
)
```

### Tooltip

Configure tooltip appearance and behavior:

```dart
SmoothHover(
  tooltipText: 'Custom tooltip',
  tooltipDelay: Duration(milliseconds: 500),
  tooltipDecoration: BoxDecoration(
    color: Colors.black87,
    borderRadius: BorderRadius.circular(4),
  ),
  child: YourWidget(),
)
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
