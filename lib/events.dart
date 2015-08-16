library pneuma.events;

import 'dart:async';

class _Event {
  final Function handler;
  final bool once;
  _Event(this.handler, this.once);
}

const int LISTENER_LIMIT = 15;

class Events {

  Map<String, List<_Event>> _events;

  void emit(String name, [dynamic data =  null]) {
    List<_Event> events = _events[name];
    if(events != null) {
      for(int i = 0, len = events.length; i < len; i++) {
        _Event event = events[i];
        event.handler(data);
        if(event.once) {
          events.removeAt(i);
        }
      }
    }
  }

  void on(String name, Function handler) {
    _addEventHandler(name, handler);
  }

  void once(String name, Function handler) {
    _addEventHandler(name, handler, true);
  }

  void _addEventHandler(String name, Function handler, [bool once = false]) {
    List events = _events[name];
    _Event event = new _Event(handler, once);
    if(events == null) {
      events = new List<_Event>(LISTENER_LIMIT);
      _events[name] = events;
    }
    events.add(event);
  }
}
