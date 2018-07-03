/*
 * Copyright (C) 2018 The jVanila Open Source Project
 * Copyright (C) 2018 The Purnatva Solutions Private limited
 *  
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *  
 *        http://www.apache.org/licenses/LICENSE-2.0
 *  
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 * author - pavan.jvanila@gmail.com
 */

library event_bus;

export 'event_subscriber.dart';
export 'event.dart';

///                                                                          ///
/// *************************************************************************///
///                           Event bus implementation                       ///
/// *************************************************************************///
///                                                                          ///

import 'dart:async';

import 'package:jvanila_flutter/src/core/typed_object_type.dart';
import 'package:jvanila_flutter/src/eventbus/event.dart';
import 'package:jvanila_flutter/src/eventbus/event_subscriber.dart';

///
/// Dispatches events to listeners using the Dart [Stream] API. The [EventBus]
/// enables decoupled applications. It allows objects to interact without
/// requiring to explicitly define listeners and keeping track of them.
///
/// Not all events should be broad-casted through the [EventBus] but only those
/// of general interest.
///
/// Events are normal Dart objects. By specifying a class, listeners can
/// filter events. Such a filter will return
/// specifying a class.
///
class EventBus {

  StreamController<Event> _streamController;

  /// Controller for the event bus stream.
  StreamController<Event> get streamController => _streamController;

  Map<Type, EventDispatcher<Event>> _dispatchers;

  ///
  /// Creates an [EventBus].
  ///
  /// If [sync] is true, events are passed directly to the stream's listeners
  /// during an [fire] call. If false (the default), the event will be passed to
  /// the listeners at a later time, after the code creating the event has
  /// completed.
  ///
  EventBus({bool sync: false}) {
    _streamController = new StreamController.broadcast(sync: sync);
    _dispatchers = new Map();
  }

  ///
  /// Listens for events of [eventType].
  ///
  /// The returned [Stream] is a broadcast stream so multiple subscriptions are
  /// allowed.
  ///
  /// Each listener is handled independently, and if they pause, only the
  /// pausing listener is affected. A paused listener will buffer events
  /// internally until un-paused or canceled. So it's usually better to just
  /// cancel and later subscribe again (avoids memory leak).
  ///
  Stream<Event> on<T extends Event>([TypeOf<T> eventType]) {
    if (eventType == null) {
      return streamController.stream;
    }
    else {
      return streamController.stream.where((event) =>
        event.runtimeType == eventType.type);
    }
  }
  
  StreamSubscription<Event> subscribe<T extends Event>(TypeOf<T> eventType,
      EventSubscriber subscriber) {

    Stream<Event> stream = on(eventType);
    StreamSubscription<Event> subscription = stream.listen(_handleEvent);

    EventDispatcher<T> typeDispatcher = _dispatchers[eventType.type];
    if (typeDispatcher == null) {
      typeDispatcher = new EventDispatcher<T>();
      _dispatchers[eventType.type] = typeDispatcher;
    }
    typeDispatcher.add(subscription, subscriber);

    return subscription;
  }

  void _handleEvent<T extends Event>(T event) {
    Type key = event.runtimeType;
    EventDispatcher<T> typeDispatcher = _dispatchers[key];
    typeDispatcher.dispatch(event);
  }

  unsubscribe<T extends Event>(TypeOf<T> eventType,
      EventSubscriber subscriber) {

    EventDispatcher<T> typeDispatcher = _dispatchers[eventType.type];
    if (typeDispatcher != null) {
      typeDispatcher.remove(subscriber);
    }
  }

  unsubscribeBy<T extends Event>(TypeOf<T> eventType,
      StreamSubscription<Event> subscription) {

    EventDispatcher<T> typeDispatcher = _dispatchers[eventType.type];
    if (typeDispatcher != null) {
      typeDispatcher.removeSubscription(subscription);
    }
  }

  unsubscribeType<T extends Event>(TypeOf<T> eventType) {
    EventDispatcher<T> typeDispatcher = _dispatchers[eventType.type];
    if (typeDispatcher != null) {
      typeDispatcher.removeAll();
    }
  }

  ///
  /// Fires a new event on the event bus with the specified [Event].
  ///
  void publish(event) {
    streamController.add(event);
  }

  ///
  /// Destroy this [EventBus]. This is generally only in a testing context.
  ///
  void destroy() {
    _streamController.close();
  }
}

///
/// The per event subscriptions and dispatch manager
///
class EventDispatcher<T extends Event> {

  List<EventSubscriber> subscribers;
  Map<EventSubscriber, SubscriptionPair> subscriptionTuple;

  EventDispatcher() {
    subscribers = [];
    subscriptionTuple = Map<EventSubscriber, SubscriptionPair>();
  }

  void dispatch(T event) {
    for (var subscriber in subscribers) {
      subscriber.onEvent(event);
    }
  }

  void add(StreamSubscription<Event> subscription, EventSubscriber subscriber) {
    if (subscribers.contains(subscriber)) {
      return;
    }

    subscribers.add(subscriber);
    subscriptionTuple[subscriber] =
      new SubscriptionPair(subscriber, subscription);
  }

  void remove(EventSubscriber subscriber) {
    if (!subscribers.contains(subscriber)) {
      return;
    }

    SubscriptionPair pair = subscriptionTuple[subscriber];
    subscribers.remove(pair.subscriber);
    subscriptionTuple.remove(pair);

    pair.subscription.cancel();
  }

  void removeSubscription(StreamSubscription<Event> subscription) {
    subscriptionTuple.forEach((key, value) {
      if (value.subscription == subscription) {
        remove(value.subscriber);
        return;
      }
    });
  }

  void removeAll() {
    subscriptionTuple.forEach((key, value) {
      value.subscription.cancel();
    });
    subscriptionTuple.clear();
    subscribers.clear();
  }
}

///
/// The internal subscriber and subscription tuple
///
class SubscriptionPair {

  final EventSubscriber subscriber;
  final StreamSubscription<Event> subscription;

  SubscriptionPair(this.subscriber, this.subscription);
}