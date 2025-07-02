# Visual Iteration Workflow

A screenshot-driven approach for UI development with Claude Code.

## Overview

Perfect for implementing designs, matching mockups, and iterating on UI until it's pixel-perfect.

## Workflow Steps

### 1. 📸 Provide Visual Reference

**Goal:** Give Claude clear visual context

**Best practices:**
- High-resolution screenshots
- Include design specs if available
- Annotate important elements
- Show different states (hover, active, etc.)

```bash
User: "Here's the design for our new dashboard [screenshot attached]"
Claude: "I can see the dashboard design with:
- Navigation sidebar on the left
- Stats cards at the top
- Chart section in the middle
- Recent activity table at the bottom"
```

### 2. 🎨 Initial Implementation

**Goal:** Create the first version matching the design

```jsx
// Claude implements based on the screenshot
const Dashboard = () => {
  return (
    <div className="flex h-screen bg-gray-50">
      {/* Sidebar */}
      <aside className="w-64 bg-white shadow-sm">
        <nav className="p-4">
          {/* Navigation items */}
        </nav>
      </aside>
      
      {/* Main content */}
      <main className="flex-1 p-6">
        {/* Stats cards */}
        <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-6">
          <StatsCard title="Total Revenue" value="$45,231" change="+12%" />
          {/* More cards... */}
        </div>
        
        {/* Charts section */}
        <div className="bg-white rounded-lg shadow p-6">
          {/* Chart implementation */}
        </div>
      </main>
    </div>
  );
};
```

### 3. 📷 Screenshot Current State

**Goal:** Show Claude what was built

```bash
Claude: "I've implemented the initial dashboard. Let me take a screenshot of the current state..."
[Claude runs the app and captures screenshot]
Claude: "Here's how it currently looks. I notice:
- The spacing might need adjustment
- Colors may need fine-tuning
- The chart area needs the actual chart component"
```

### 4. 🔄 Iterate Based on Feedback

**Goal:** Refine until it matches the design

```bash
User: "The stats cards need more padding and the shadows are too strong"

Claude: "I'll adjust the styling:"
```

```jsx
// Refined implementation
<div className="bg-white rounded-xl shadow-sm p-6"> {/* Increased padding, softer shadow */}
  <div className="flex items-center justify-between">
    <div>
      <p className="text-sm font-medium text-gray-600">Total Revenue</p>
      <p className="text-2xl font-semibold text-gray-900 mt-1">$45,231</p>
    </div>
    <div className="flex items-center text-sm font-medium text-green-600">
      <TrendingUpIcon className="w-4 h-4 mr-1" />
      +12%
    </div>
  </div>
</div>
```

### 5. ✅ Final Verification

**Goal:** Confirm implementation matches design

```bash
Claude: "Here's the final implementation [screenshot]. 
The dashboard now includes:
- Properly spaced stats cards with subtle shadows
- Responsive grid layout
- Matching color scheme
- All interactive elements"

User: "Perfect! The implementation matches the design."
```

## Example Visual Iteration Session

```bash
# Step 1: User provides mockup
User: "Implement this login page design [attaches Figma screenshot]"

# Step 2: Claude analyzes
Claude: "I can see a centered login form with:
- Company logo at top
- Email and password fields
- 'Remember me' checkbox
- Blue submit button
- 'Forgot password?' link
- Social login options at bottom
Let me implement this..."

# Step 3: Initial implementation
Claude: [Creates login component with Tailwind CSS]

# Step 4: Screenshot and compare
Claude: "Here's my implementation [screenshot]. Comparing to your design:
- ✅ Layout structure matches
- ⚠️ Button color needs adjustment (#4F46E5 instead of current blue)
- ⚠️ Input fields need more height
- ⚠️ Social buttons spacing needs work"

# Step 5: User feedback
User: "Yes, please fix those issues. Also, the logo should be larger"

# Step 6: Iterate
Claude: "I'll make these adjustments..."
[Updates styles]
"Here's the updated version [screenshot]. Changes made:
- Button now uses the exact hex color
- Input fields increased to h-12
- Logo scaled up by 1.5x
- Social buttons properly spaced"

# Step 7: Final touches
User: "Great! Just add a subtle shadow to the form container"

Claude: "Added shadow-lg to the form container. Here's the final result [screenshot]"
```

## Tips for Effective Visual Iteration

### 1. Screenshot Best Practices

**For Design References:**
- Include the full context
- Show responsive breakpoints
- Capture interactive states
- Include color/spacing annotations

**For Current Implementation:**
- Show in target browser
- Include developer tools if relevant
- Capture different screen sizes
- Show both light/dark modes if applicable

### 2. Communication Strategies

**Be Specific About:**
```bash
# ❌ Vague
"Make it look better"

# ✅ Specific
"Increase the padding to 24px and use the brand blue #3B82F6"
```

**Provide Measurements:**
```bash
# Include specific values
"The cards should be 280px wide with 16px gap between them"
"Use 14px font size for body text, 18px for headings"
```

### 3. Component Organization

```jsx
// Break down complex UIs into components
const Dashboard = () => {
  return (
    <DashboardLayout>
      <DashboardHeader />
      <StatsSection />
      <ChartsSection />
      <ActivityFeed />
    </DashboardLayout>
  );
};

// Iterate on individual components
const StatsCard = ({ title, value, change, icon }) => {
  // Component-specific styling
};
```

### 4. Responsive Design

```bash
# Test at different breakpoints
User: "Show me how it looks on mobile (375px) and tablet (768px)"

Claude: "I'll capture screenshots at different breakpoints:
- Mobile (375px): [screenshot]
- Tablet (768px): [screenshot]
- Desktop (1440px): [screenshot]"
```

## Advanced Techniques

### 1. Design System Integration

```jsx
// Use design tokens for consistency
const theme = {
  colors: {
    primary: '#3B82F6',
    secondary: '#10B981',
    // ... from design system
  },
  spacing: {
    xs: '4px',
    sm: '8px',
    md: '16px',
    // ... standardized spacing
  }
};
```

### 2. Animation and Transitions

```bash
User: "Add smooth transitions like in this prototype [video/gif]"

Claude: "I'll add CSS transitions and animations:
- Hover effects with 200ms ease
- Slide-in animations for modals
- Smooth color transitions"
```

### 3. Accessibility Considerations

```jsx
// Ensure visual changes maintain accessibility
<button 
  className="bg-blue-600 hover:bg-blue-700 focus:ring-2 focus:ring-blue-500"
  aria-label="Submit form"
>
  Submit
</button>
```

## Common Patterns

### Card-Based Layouts
```jsx
<div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
  {items.map(item => (
    <Card key={item.id} {...item} />
  ))}
</div>
```

### Navigation Headers
```jsx
<header className="sticky top-0 z-50 bg-white border-b">
  <nav className="container mx-auto px-4 h-16 flex items-center justify-between">
    {/* Logo and navigation */}
  </nav>
</header>
```

### Form Layouts
```jsx
<form className="space-y-4 max-w-md mx-auto">
  <div>
    <label className="block text-sm font-medium mb-2">
      Email
    </label>
    <input className="w-full px-4 py-2 border rounded-lg" />
  </div>
  {/* More fields */}
</form>
```

## Troubleshooting

### Common Issues

1. **Colors don't match**
   - Use exact hex/rgb values
   - Check color profiles
   - Consider opacity/transparency

2. **Spacing is off**
   - Use browser DevTools
   - Measure with screenshot tools
   - Check box model (padding vs margin)

3. **Responsive issues**
   - Test at exact breakpoints
   - Use responsive utilities
   - Consider fluid typography

## When to Use This Workflow

✅ **Ideal for:**
- Implementing designs from Figma/Sketch
- Matching existing UI patterns
- Creating marketing pages
- Building dashboards
- Developing component libraries

❌ **Not ideal for:**
- Backend logic
- API development
- Database design
- Performance optimization