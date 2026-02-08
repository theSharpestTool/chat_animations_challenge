# Advanced Chat Animations

A Flutter project that demonstrates advanced chat UI animations.

The app focuses on the message sending flow and shows how to combine overlay
transitions, placeholder layout animation, and coordinated label animations to
create a smooth chat experience.

## GIF Example



## Demo Focus

- Bubble transition from input field to chat list (overlay animation).
- Placeholder expansion to reserve list space during transition.
- Coordinated "Delivered" label scale + fade animation.
- Message state flow: `sending` -> `delivered`.

## Project Structure

```text
lib/
  main.dart
  chat/
    models/
      chat_message.dart
    view/
      chat_screen.dart
      widgets/
        bubble.dart
        delivered_label.dart
        animations/
          bubble_placeholder.dart
          bubble_transition.dart
          delivered_label_fade.dart
          delivered_label_scale.dart
```

## How It Works

1. User types a message and taps send.
2. A flying bubble is rendered in an `OverlayEntry` and animated from the input
   field to a bubble placeholder location in the list.
3. After transition, the message is shown in the "animating" section.
4. A short simulated delay represents network delivery.
5. Slide/fade/scale animations move the message to the delivered section and
   update the "Delivered" label.

## Run Locally

```bash
flutter pub get
flutter run
```

## Why This Project

Use this project as a reference for:

- Coordinating multiple Flutter animation controllers.
- Combining `CustomScrollView` + `Sliver` widgets with animated states.
- Building polished chat interactions with explicit animation phases.
