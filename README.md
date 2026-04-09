# jeffy-events 2.0
> [!WARNING]
> This is still in active development and is NOT ready for use

A graph based event sequencer for Godot 4.6. This addon is a designer friendly solution for game event sequencing, e.g. things like cutscenes and NPC interactions. Sequencing tends to be done through script, or through something like Godot's animation timeline. This is my proposed solution, which tries to strike a balance between minimal code for the programmer and minimal effort required for the designer.

Events are small interfaces; they have one main method, and a few extraneous ones for frontend. As someone who hates wrangling GUI code, my solution is to let the programmer declare what they want in the event interface via code. This uses a builder system that is easily extensible if you want to add your own elements. Regardless, if you want more control, you can still manually create UI for events as their own scene files.

This addon doesnt stop at JUST sequencing, though. There is support for advanced usage via dependency injection. You can create simple graph templates with placeholder values, and reuse them across your game.

JeffyEvents aims to be unintrusive to existing systems that may exist in your project; as such all classes are namespaced with "JEP_" and the addon only ships with general purpose events. If you want a frame of reference on how events are created, you can check out some of the optional modules that are licensed under MIT (free to use in your projects!)

## Usage
To use JeffyEvents, just install the addon from the Godot asset library. TBD

## Roadmap
Not a finalized list
- [ ] Frontend
  - [ ] Side menu 
    - [ ] Sources pane
      - [x] Adding sources
      - [x] Removing sources
      - [x] Refreshing sources
      - [ ] Searching sources/events 
    - [ ] Opened graphs pane
      - [x] Creating graphs
      - [ ] Closing graphs
      - [x] Save monitoring (mark as unsaved) 
  - [ ] Graph menu
    - [ ] Change monitoring (switching focused graph on demand)
    - [ ] Graph pane
    - [ ] Labels pane
    - [ ] Variables pane
  - [ ] Event frontend
    - [ ] UI instructions
      - [ ] Instruction builder class
      - [ ] Property builder classes
    - [ ] Instruction parsing
  - [ ] UndoRedo support
- [ ] Backend
  - [ ] EventGraphExecutor
    - [ ] Traversal
    - [ ] Dependency resolution
  - [x] Event 

## Design quirks
Regarding how UI is generated; GDScript does not offer preprocessor directives, which means that UI generation code is compiled and included in release builds of your game. Instead of directly building UI, and therefore referencing editor specific classes in exported builds (bad, throws lots of errors!) It will instead create a list of instructions formatted in JSON, which has no references to editor specific classes (good!) Unfortunately, this adds a bit of additional complexity when it comes to adding your own custom builder classes; you must create both the JSON instruction set and code to parse and construct UI based on those instructions.

TBD
