# DialogView Test Data

This directory contains test data and screenshots for the `DialogView` component (`_macOS/DocketMate/Views/Common/DialogView.swift`).

## Contents

- **Screenshots**: Visual captures of the `DialogView` component in different states and configurations
- **Test Cases**: JSON files with test configurations for the `DialogView` component
- **Expected Results**: Documentation of expected behaviors and appearances

## Usage for Visual Testing

When making changes to the `DialogView` component or related UI elements, use these test assets to:

1. **Compare Visual Consistency**: Ensure changes don't unintentionally alter the appearance
2. **Verify Animation Behavior**: Check that animations work as expected (including continuous icon rotation, staggered feature appearance, and subtle hover effects)
3. **Validate Variants**: Test different configurations (feature counts, message lengths, etc.)
4. **Accessibility Testing**: Verify component works well with VoiceOver and keyboard navigation (including Escape key dismissal)
5. **Interaction Testing**: Verify hover states, button press animations, and feature icon interactions

## Adding New Test Data

When adding new test cases or screenshots:

1. Use descriptive filenames that indicate what's being tested
2. Include both light and dark mode variations when relevant
3. Document edge cases (very long text, many/few features, etc.)
4. Update this README.md if necessary

## Component Parameters for Testing

The `DialogView` component accepts these parameters that should be varied in tests:

```swift
DialogView(
    isPresented: Binding<Bool>,
    title: String,              // Test with short and long titles
    subtitle: String,           // Test with short and long subtitles
    message: String,            // Test with short, long, and multi-paragraph messages
    features: [(icon: String, text: String)], // Test with 0, 1, 3, and 5+ features
    buttonText: String,         // Test with short and long button text
    iconName: String,           // Test with different SF Symbol icons
    onDismiss: (() -> Void)?    // Test with and without custom dismiss handler
)
```

## Animation Tests

The DialogView includes several animations that should be tested:

1. **Entry Animations**:
   - Main dialog scale and fade in
   - Message text fade and slide in
   - Staggered feature bullets appearance
   - Button scale in

2. **Continuous Animations**:
   - Subtle icon rotation (20 second duration)

3. **Interactive Animations**:
   - Feature icons scaling on hover
   - Button scaling on press
   - Dismissal animations (scale and fade out)

## Visual Test Checklist

- [ ] Entry animation sequence is smooth and well-timed
- [ ] Exit animation works when:
  - [ ] Tapping outside the dialog
  - [ ] Tapping the close button
  - [ ] Pressing the main action button
  - [ ] Pressing the Escape key
- [ ] Gradient background with pattern elements renders correctly
- [ ] Edge highlight on the dialog adds subtle depth
- [ ] Feature bullets appear with staggered animation
- [ ] Feature icons scale up slightly on hover
- [ ] "Don't show again" toggle works and persists
- [ ] Button shows a subtle scale/opacity change when pressed
- [ ] Icon rotates continuously with subtle animation
- [ ] Text doesn't overflow or get truncated with longer content
- [ ] Background blur/overlay covers entire screen properly
- [ ] Shine effects are visible in dark mode
- [ ] All animations respect user's reduced motion settings

## Accessibility Checklist

- [ ] All interactive elements have proper accessibility labels
- [ ] Component correctly identifies as a modal
- [ ] Tab navigation works correctly within the dialog
- [ ] Escape key dismisses the dialog
- [ ] Toggle state is properly announced by screen readers
- [ ] Custom onDismiss handler is called when dialog is closed 