# Prompt System Guide

## Overview

The Prompt System allows users to create, manage, and use custom AI prompts. Prompts are templates that define how text is processed by AI providers.

## Built-in Prompts

The app includes 24 built-in prompts covering common reading scenarios:

### Reading & Comprehension
- **Simplify English** - Rewrites text in simple language
- **Reading Coach** - Helps improve reading comprehension
- **Book Discussion** - Facilitates thoughtful discussions

### Translation
- **Translate to Hindi** - Full Hindi translation
- **Translate to Urdu** - Full Urdu translation
- **Translate to Hinglish** - Mixed Hindi-English translation

### Explanation Levels
- **Explain Like Beginner** - Simple explanation with analogies
- **Explain Like Teacher** - Structured educational explanation
- **Explain Like Professor** - Scholarly analysis

### Language Analysis
- **Explain Idioms** - Identifies and explains figurative language
- **Explain Phrases** - Explains notable expressions
- **Vocabulary Builder** - Builds word knowledge from text

### Summarization
- **Summarize Page** - Brief page-level summary
- **Summarize Chapter** - Detailed chapter summary

### Learning & Study
- **Generate Notes** - Structured study notes
- **Generate Flashcards** - Q&A flashcard creation
- **Quiz Me** - Interactive quiz generation

### Professional
- **Research Assistant** - Academic text analysis
- **Academic Simplifier** - Makes academic text accessible
- **Legal Simplifier** - Plain language legal explanations
- **Medical Simplifier** - Patient-friendly medical explanations

### Memory & Context
- **Memory Refresh** - Recap of previously read text
- **What Did I Read?** - Reading context recovery
- **Explain Previous Context** - Connects current text to earlier reading

## Prompt Structure

Each prompt has:
```dart
class Prompt {
    String title;        // Display name
    String content;      // The prompt template with {text} placeholder
    String? category;    // Grouping category
    List<String> tags;   // Searchable tags
    bool isFavorite;     // Starred for quick access
    bool isDefault;      // Used for quick actions
    bool isBuiltIn;      // Pre-installed prompt
    int sortOrder;       // Display order
}
```

## Creating Custom Prompts

### Via App UI
1. Go to Prompts tab
2. Tap "+" FAB button
3. Enter title and prompt content
4. Use `{text}` where reading content should be inserted
5. Add category and tags
6. Save

### Via Import
Import prompts as JSON:
```json
[
  {
    "title": "My Custom Prompt",
    "content": "Process this text: {text}",
    "category": "Custom",
    "tags": ["custom", "analysis"],
    "isFavorite": false
  }
]
```

## Using Prompts

### As Quick Actions
When a prompt is marked as "Default", it appears in the quick action list:

1. Tap the floating button
2. Default prompt appears as a quick option
3. Tap to apply to current text

### In Chat
1. Open the Chat tab
2. Select a prompt from the library
3. The prompt template loads in the input
4. Current reading context is automatically inserted

### With Shared Text
1. Select text in another app
2. Share to ReadWise AI Assistant
3. Choose a prompt action
4. Result appears in overlay card

## Prompt Templates

### Using {text} Placeholder
The `{text}` placeholder is automatically replaced with the user's current reading text:
```
Explain the following concept in detail:
{text}

Focus on practical examples.
```

### System Prompts
The app also supports a system prompt configuration that sets the AI assistant's behavior:
```
You are a helpful reading assistant that explains text clearly...
```

## Managing Prompts

### Organizing
- **Categories:** Group prompts by purpose (Reading, Translation, Academic, etc.)
- **Tags:** Add searchable tags for filtering
- **Favorites:** Star frequently used prompts for quick access

### Editing
Tap any prompt to edit its title, content, category, and tags.

### Duplicating
Create variations of existing prompts to experiment with different phrasings.

### Deleting
Remove custom prompts. Built-in prompts cannot be deleted.

### Export/Import
- Export prompts as JSON for sharing or backup
- Import prompts from JSON files
- Useful for team sharing or migrating configurations

## Best Practices

1. **Be Specific** - Clear instructions yield better AI responses
2. **Use Examples** - Show the AI what format you want
3. **Set Constraints** - Specify length, format, or style
4. **Test and Iterate** - Refine prompts based on results
5. **Organize with Tags** - Makes prompts easy to find
6. **Favorites for Speed** - Mark frequent prompts as favorites
7. **Default for Quick Actions** - One prompt can be set as default
