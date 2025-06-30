# Principles Extracted from User Feedback

## UI/UX Design Principles

### 1. Visual Hierarchy and Emphasis
- **Principle**: Important text should be visually dominant
- **Example**: "Welcome to the Construct" - you wanted "Construct" to be the largest, with "Welcome to the" being half the size
- **Application**: Always consider which element is the focal point and size accordingly

### 2. Subtle Secondary Elements
- **Principle**: Supporting text should be lighter/more transparent than primary content
- **Example**: "There is no spoon" and "Welcome to the" both use half-tone (20-40% opacity)
- **Application**: Use opacity to create visual hierarchy without removing elements

### 3. Consistent Visual Language
- **Principle**: Similar UI elements should have consistent styling across the app
- **Example**: Shift symbols (⇧) should appear the same way in sheet music and on piano keys
- **Application**: Create reusable patterns for common UI elements

## Navigation & Information Architecture

### 4. Consolidation Over Proliferation
- **Principle**: Group related features under hub pages rather than having many top-level links
- **Example**: "Music" hub containing Piano and Artists, rather than separate links
- **Application**: Create category hubs when you have 3+ related features

### 5. Contextual Grouping for Large Lists
- **Principle**: When displaying many items (>10), group them by logical categories
- **Example**: Pop songs grouped by decade/gender, Artists grouped by era
- **Application**: Always consider grouping when lists exceed ~10 items

### 6. Progressive Disclosure
- **Principle**: Show preview of categories with "View all" option
- **Example**: "All Songs" view shows 6 songs per category with link to see more
- **Application**: Don't overwhelm users - show samples and let them drill down

## Functionality & Features

### 7. Settings Consolidation
- **Principle**: User preferences and configurations belong in Settings
- **Example**: Character Select, Goals, Rankings, Analytics all moved to Settings
- **Application**: Keep main navigation for primary actions, settings for configuration

### 8. Respect User Preferences
- **Principle**: User-selected preferences should apply throughout the app
- **Example**: Selected languages should be used everywhere, not hard-coded
- **Application**: Always check user preferences before using defaults

### 9. Rich Metadata Display
- **Principle**: Show relevant metadata where it adds value
- **Example**: Artist name and year on piano practice page, not just in library
- **Application**: Consider what information helps users in each context

## Technical Implementation

### 10. Closure-Safe Animation Patterns
- **Principle**: Use refs for values that change during long-running operations
- **Example**: FallingNotes animation using refs to avoid stale closures
- **Application**: Always use refs in animation loops or intervals

### 11. Clickable Entities Create Pages
- **Principle**: If something is clickable (like artist names), it should lead somewhere meaningful
- **Example**: Artist names link to artist pages with all their songs
- **Application**: Never create dead-end navigation

### 12. No Mock Data in Production
- **Principle**: Mock data should ONLY be used for initial UI development
- **Example**: Voice learning was falling back to mock data instead of showing proper empty state
- **Application**: APIs must return real data or proper error states, UI must indicate when data is missing
- **Rule**: Never use getMockData() functions in production code - only in test files

## Visual Details

### 13. Proportional Sizing
- **Principle**: UI elements should maintain proper proportions
- **Example**: Shift symbol needed to be wider but not taller
- **Application**: Consider both dimensions when sizing elements

### 14. Proper Positioning and Spacing
- **Principle**: Small positioning adjustments matter for polish
- **Example**: Shift symbol positioning iterations to get it "just right"
- **Application**: Be prepared to iterate on positioning for visual balance

### 15. Functional Color Choices
- **Principle**: Color opacity should ensure readability
- **Example**: Shift symbol on white keys needed to match key letter darkness
- **Application**: Always test contrast and visibility in context

## Content Organization

### 16. Historical Context Matters
- **Principle**: Include relevant historical information for cultural items
- **Example**: Song years for famous tracks
- **Application**: Consider what metadata provides valuable context

### 17. Natural Language in UI
- **Principle**: Use conversational, clear language
- **Example**: "Back to Music" instead of just "Back"
- **Application**: Be specific about navigation destinations

## Implementation Strategy

### 18. Complete the Feature
- **Principle**: Implement all aspects of a feature, not just the UI
- **Example**: Piano autoplay needed the actual playback logic, not just buttons
- **Application**: Think through the full user journey

### 19. Consistent Patterns Across Similar Features
- **Principle**: Similar features should work the same way
- **Example**: All "Back" buttons should follow the same navigation hierarchy
- **Application**: Establish patterns and follow them consistently

### 20. Test in Context
- **Principle**: Always verify changes in the actual usage context
- **Example**: Sheet music shift indicators needed to match piano implementation
- **Application**: Check related features when making changes

### 21. Real Data Only in Production
- **Principle**: Production code must use real data from databases/APIs
- **Example**: Voice learning should query database, not fall back to hardcoded vocabulary
- **Application**: Show proper empty states, loading indicators, and error messages
- **Rule**: Mock data belongs only in initial prototypes and test files

### 22. Intuitive UI Without Instructions
- **Principle**: UI should be so intuitive that users don't need explanatory text or instructions
- **Example**: Default answer selection doesn't need "Click to unset" text - users will figure it out
- **Application**: Avoid dynamic help text, tooltips with obvious instructions, or UI that changes to explain itself
- **Rule**: If you need to explain how to use a UI element, redesign it to be more intuitive

### 23. Apparent Gap Principle - Zero-Out Spacing
- **Principle**: Users think in terms of visual gaps, not technical implementation
- **Example**: "Make the gap 8px" means 8px of visual space, not CSS gap property
- **Application**: Zero out all padding/margins on elements, control spacing ONLY through gaps
- **Rule**: Each edge between elements should have exactly ONE spacing value controlling it
- **Implementation**:
  - Set padding: 0, margin: 0 on grid items
  - Use gap properties for ALL spacing
  - Internal content can have padding, but container edges must be zero