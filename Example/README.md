# MarkdownTextView Example App

This example app demonstrates the MarkdownTextView library with comprehensive testing capabilities.

## Features

### Main Demo (ContentView)
- **Interactive Demo**: Basic markdown editing with live formatting
- **Syntax Showcase**: Complete demonstration of all supported markdown syntax
- **Performance Test**: Large document testing (3000+ words)
- **Real-time Character Count**: Monitor document size
- **Demo Controls**: Clear, load demo content, and syntax testing

### Advanced Testing (Gear Icon)
- **Performance Monitoring**: Real-time parse time measurement
- **Stress Testing**: Generate large documents for performance validation
- **Comprehensive Syntax Testing**: Edge cases and mixed formatting
- **Visual Performance Feedback**: Color-coded parse time indicators
  - 🟢 Green: <5ms (excellent)
  - 🟠 Orange: 5-10ms (good)
  - 🔴 Red: >10ms (needs optimization)

## Running the Example

### Prerequisites
- Xcode 15.0+
- iOS 16.0+ (Simulator or Device)
- Swift 6.0+

### Steps
1. **Open in Xcode**:
   ```bash
   cd MarkdownTextView/Example
   open MarkdownExample.xcodeproj
   ```

2. **Build and Run**:
   - Select target device/simulator
   - Press Cmd+R or click the Run button
   - The app will build the MarkdownTextView package automatically

3. **Testing the Features**:
   - Start with the main demo to test basic functionality
   - Use the segmented control to switch between demo types
   - Tap the gear icon for advanced testing features
   - Monitor performance metrics while typing

## What to Test

### Basic Functionality
- [x] **Bold**: `**text**` and `__text__`
- [x] **Italic**: `*text*` and `_text_`
- [x] **Headers**: `#` through `######`
- [x] **Inline Code**: `` `code` ``
- [x] **Strikethrough**: `~~text~~`

### Performance Requirements
- [x] **Parse Time**: Should be <10ms for documents up to 3000 words
- [x] **Typing Latency**: Should be <1ms for real-time feedback
- [x] **Memory Usage**: Monitor for memory leaks during extended use

### Edge Cases
- [x] **Incomplete Syntax**: Test unclosed markers
- [x] **Mixed Formatting**: Nested and combined formatting types
- [x] **Rapid Typing**: Stress test with fast input
- [x] **Large Documents**: 3000+ word performance validation

## Known Limitations (Phase 1)
- Syntax markers are always visible (hiding comes in Phase 2)
- No animations yet (Bear-like animations in Phase 2)
- Limited to basic markdown syntax (links, lists, etc. in future phases)

## Troubleshooting

### Build Issues
If you encounter build issues:
1. Clean build folder: Product → Clean Build Folder
2. Delete derived data: Xcode → Preferences → Locations → Derived Data → Delete
3. Ensure iOS 16.0+ deployment target

### Performance Issues
If parse times exceed 10ms:
1. Check document size (should be ≤3000 words)
2. Review system resources
3. Test on physical device vs simulator

## Next Steps
This example app will be extended in Phase 2 to demonstrate:
- Bear-like syntax hiding animations
- Cursor-aware marker visibility
- Advanced navigation and selection behavior
- Theme system integration