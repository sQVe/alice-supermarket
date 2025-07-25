# Alice Supermarket - Project Structure

## File Organization

### Root Directory Structure

```
alice-supermarket/
├── project.godot                 # Godot project file
├── assets/                       # All game assets
├── scenes/                       # Game scenes organized by learning topic
├── scripts/                      # GDScript files organized by functionality
├── localization/                 # Translation files (Swedish/English)
├── addons/                       # Third-party plugins
├── tests/                        # Automated test files
└── export_presets.cfg           # Platform export settings
```

## Asset Organization

### Assets Directory

```
assets/
├── graphics/
│   ├── characters/              # Alice and customer sprites
│   ├── shop/                    # Shop interior and items
│   ├── ui/                      # Interface elements
│   └── kenney/                  # Kenney asset collections by category
├── audio/
│   ├── sfx/                     # Sound effects
│   ├── music/                   # Background music
│   └── tts/                     # Text-to-speech audio files
└── fonts/                       # Game fonts for both languages
```

## Scene Organization (By Learning Topic)

### Scenes Directory Structure

```
scenes/
├── main/                        # Core game scenes
│   ├── main_menu.tscn
│   ├── shop_main.tscn
│   └── settings.tscn
├── math/                        # Mathematics learning scenes
│   ├── counting/
│   │   ├── basic_counting.tscn
│   │   ├── item_counting.tscn
│   │   └── money_counting.tscn
│   ├── addition/
│   │   ├── simple_addition.tscn
│   │   └── cash_register.tscn
│   └── subtraction/
│       ├── change_making.tscn
│       └── inventory_reduction.tscn
├── reading/                     # Reading skill scenes
│   ├── letters/
│   │   ├── letter_recognition.tscn
│   │   └── alphabet_sorting.tscn
│   ├── words/
│   │   ├── product_names.tscn
│   │   ├── shopping_list.tscn
│   │   └── customer_orders.tscn
│   └── comprehension/
│       ├── recipe_reading.tscn
│       └── instruction_following.tscn
├── writing/                     # Writing skill scenes
│   ├── tracing/
│   │   ├── letter_tracing.tscn
│   │   └── number_tracing.tscn
│   ├── spelling/
│   │   ├── product_spelling.tscn
│   │   └── word_completion.tscn
│   └── composition/
│       ├── list_making.tscn
│       └── order_writing.tscn
└── ui/                          # Reusable UI components
    ├── progress_bar.tscn
    ├── skill_meter.tscn
    ├── reward_popup.tscn
    └── language_selector.tscn
```

## Script Organization (By Functionality)

### Scripts Directory Structure

```
scripts/
├── core/                        # Core game systems
│   ├── game_manager.gd         # Main game state management
│   ├── scene_loader.gd         # Scene transition handling
│   ├── save_system.gd          # Save/load functionality
│   └── settings_manager.gd     # Game settings and preferences
├── ui/                          # User interface scripts
│   ├── main_menu.gd
│   ├── pause_menu.gd
│   ├── progress_ui.gd
│   ├── reward_system.gd
│   └── language_switcher.gd
├── education/                   # Educational logic
│   ├── skill_tracker.gd        # Track learning progress
│   ├── difficulty_manager.gd   # Adaptive difficulty system
│   ├── assessment.gd           # Skill assessment logic
│   └── feedback_system.gd     # Educational feedback
├── gameplay/                    # Game mechanics
│   ├── shop_management.gd      # Shop simulation logic
│   ├── customer_ai.gd          # Customer behavior
│   ├── inventory_system.gd     # Item management
│   ├── currency_system.gd      # Money and purchasing
│   └── customization.gd        # Shop customization
├── learning/                    # Subject-specific logic
│   ├── math/
│   │   ├── counting_logic.gd
│   │   ├── addition_logic.gd
│   │   └── subtraction_logic.gd
│   ├── reading/
│   │   ├── letter_recognition.gd
│   │   ├── word_matching.gd
│   │   └── comprehension.gd
│   └── writing/
│       ├── tracing_validation.gd
│       ├── spelling_checker.gd
│       └── composition_helper.gd
├── audio/                       # Audio management
│   ├── audio_manager.gd        # Central audio control
│   ├── tts_system.gd          # Text-to-speech integration
│   └── music_controller.gd    # Background music
└── utilities/                   # Helper functions
    ├── math_utils.gd           # Mathematical calculations
    ├── string_utils.gd         # Text processing
    ├── animation_utils.gd      # Animation helpers
    └── localization_utils.gd   # Translation helpers
```

## Naming Conventions

### Files and Directories

- **Scenes**: snake_case.tscn (e.g., `basic_counting.tscn`)
- **Scripts**: snake_case.gd (e.g., `skill_tracker.gd`)
- **Assets**: snake_case with descriptive names
- **Directories**: lowercase with underscores

### GDScript Code

- **Classes**: PascalCase (e.g., `SkillTracker`)
- **Variables**: snake_case (e.g., `player_score`)
- **Functions**: snake_case (e.g., `calculate_progress()`)
- **Constants**: UPPER_SNAKE_CASE (e.g., `MAX_SKILL_LEVEL`)
- **Signals**: snake_case with descriptive names (e.g., `skill_improved`)

### Scene Node Names

- **UI Elements**: PascalCase (e.g., `ProgressBar`, `RewardButton`)
- **Game Objects**: PascalCase (e.g., `ShopCounter`, `CustomerNPC`)
- **Containers**: Descriptive PascalCase (e.g., `MainContainer`, `SkillPanel`)

## Localization Structure

### Translation Files

```
localization/
├── translations.csv             # Master translation file
├── strings_en.po               # English translations
├── strings_sv.po               # Swedish translations
└── audio_keys.json             # TTS pronunciation keys
```

### Resource Naming

- **Translation Keys**: UPPER_SNAKE_CASE (e.g., `WELCOME_MESSAGE`)
- **Audio Files**: snake_case with language prefix (e.g., `en_welcome.ogg`)

## Testing Structure

### Test Organization

```
tests/
├── unit/                        # Unit tests for individual functions
│   ├── education/
│   ├── gameplay/
│   └── utilities/
├── integration/                 # Integration tests for systems
│   ├── save_load_test.gd
│   ├── skill_progression_test.gd
│   └── localization_test.gd
└── fixtures/                    # Test data and mock objects
    ├── sample_progress.json
    └── test_translations.csv
```

## Development Workflow Files

### Configuration Files

- **gdformat.cfg**: Code formatting configuration
- **pre-commit-config.yaml**: Git hooks for quality assurance
- **export_presets.cfg**: Platform-specific export settings
- **.gitignore**: Exclude temporary and build files

### Documentation

- **README.md**: Project overview and setup instructions
- **CHANGELOG.md**: Version history and updates
- **CONTRIBUTING.md**: Development guidelines for contributors

## Best Practices

### Scene Design

- Keep scenes focused on single learning objectives
- Use consistent node naming across similar scenes
- Separate UI layout from game logic scripts
- Design for reusability across learning topics

### Script Organization

- One class per file with matching filename
- Group related functionality in directories
- Use composition over inheritance where possible
- Keep educational logic separate from game mechanics

### Asset Management

- Organize assets by category and learning topic
- Use consistent naming for similar asset types
- Optimize assets for mobile performance
- Maintain asset attribution for Kenney resources

### Version Control

- Commit by feature or learning topic
- Use meaningful commit messages
- Keep binary assets in appropriate directories
- Tag releases for major milestones
