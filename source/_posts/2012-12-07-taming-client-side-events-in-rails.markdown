---
layout: post
title: "Taming Client Side Events in Rails"
date: 2012-12-07 16:25
comments: true
categories: [javascript, coffeescript, ruby, rails, jquery, jquery-ujs, backbone, backbonejs]
---

Passing `:remote => true` to `:link_to` and `:form_for` is a nice convention for implementing ajax in a rails app. So simple, so pretty, so far.

If you continue using jquery-ujs by the book, you end up with a lot of this:
```javascript
$('#some_ujs_targeted_element').on('ajax:complete', function(event, xhr, status) {

  // do stuff...

});
```

...and that's cool.

The `ajax:complete` event is a jquery event triggered by the jquery-ujs library. At the time of writing this, there are a total of 7 published [jquery-ujs events](https://github.com/rails/jquery-ujs/wiki/ajax). There's also 10 (native) [jquery ajax events](http://docs.jquery.com/Ajax_Events) that communicate just about the same information.

jquery-ujs
```
ajax:before
ajax:beforeSend
ajax:success
ajax:error
ajax:complete
ajax:aborted:required
ajax:aborted:file
```

jquery
```
ajaxStart
beforeSend
ajaxSend
success
ajaxSuccess
error
ajaxError
complete
ajaxComplete
ajaxStop
```

So I guess I would call the jquery-ujs ajax events an abstraction of the native jquery ajax events (with the exception of [ajax:aborted](http://www.alfajango.com/blog/new-ajax-aborted-rails-jquery-ujs-callbacks/), but I don't want to get into that). Nicely done, but I'm not sure it's a very useful abstraction. Maybe it could be argued that the jquery-ujs events are a bit more manageable (being that there's less of them or something). To me there's no obvious reason to use one group of events over the other.

Another consideration to make is how to organize listeners. As a project grows, the more code there will be listening to and handling ajax events. It can get tough keeping track of what is listening and where it lives.

So there are a few problems I'd like to propose solutions for - which events should be listened to, how to keep track of what is listening, and how handlers are notified of events.

### Which events should be listened to.

It doesn't really matter. :\ The forementioned events are all really important, but they should each (if each) be listened for in 1 single place of an application. For any other part of the application to leverage these events, they should observe the observer.

### An implementation.

```coffeescript
$(document).bind 'ajaxComplete', (e, xhr, options)->
  data = (->
    try
      return $.parseJSON(xhr.responseText)
    catch error
      # :(
  )()
  if data.events
    $(data.events).each (i, event)->
      SomeRadNameSpace.trigger event.name, event.data
```

Above I chose to use the `ajaxComplete` event, parse what's expected to be JSON, and then do something with an anticipated array called `events`. Using this approach means you'd need to render a data structure that looks like this: `{ :events => [{ :name => Object, :data => Object }]}`. This shouldn't need to vary among controllers so a module could be created to instantiate this hash.

```ruby
module ClientSideEvent

  # Public: builds a hash for triggering events.
  #
  # *events - any number of arrays containing event data
  #           [0] is always the name of the event/private method (w/o cse_ prefix) that builds the desired event.
  #           [1..] are whatever arguments the method expects.
  #
  # Examples
  #
  #   render :json => client_side_event(['authenticate', i18n_message])
  #   # => { :events => { :name => 'authenticate', :data => { :message => 'whatever i18n_message is' } }
  #
  # Returns a Hash
  def client_side_event(*events)
    { :events =>
      events.map do |event|
        { :name => event[0], :data => self.send("cse_#{event.slice!(0)}", *event) }
      end
    }
  end

  # Private: For creating unique client side events whose arguments are better managed from its caller.
  #
  # Leveraging this method should mean that the event has only 1 caller and at least one of the following statements are true:
  #
  # - the event has no arguments.
  # - the event has very simple arguments.
  # - the event has very few (like 1) subscriber(s) client side.
  def method_missing(meth, *args, &block)
    case args.size
    when 0
    when 1 # no need for an array
      args.first
    else # stays an array
      args
    end
  end

  # the cse prefix is to prevent namespace collisions when including this module.

  def cse_authenticate(message, attempted_path)
    { :message => message, :attempted_path => attempted_path }
  end

  def cse_flash_message(type, message)
    raise "#{type} is not a usable flash event type" unless [:alert, :notice, :error, :success].include? type
    { :type => type, :message => message }
  end
end
```

A controller could then look like this:

```ruby
require 'client_side_event'

class SomeController < ApplicationController

  include ClientSideEvent

  def hola
    render :json => client_side_event(
      [:authenticate, 'who are you?', '/hola'],
      [:flash_message, :alert, 'to be or...'],
      [:some_relevant_notification, { :some_relevant_key => 'some relevant value' }]
    )
  end
end
```

The `:hola` action will render this:

```json
{
  "events": [
    "authenticate": {
      "message": "who are you?",
      "attempted_path": "/hola"
    },
    "flash_message": {
      "type": "alert",
      "message": "to be or..."
    },
    "some_relevant_notification": {
      "some_relevant_key": "some relevant value"
    }
  ]
}
```

There is a javascript method called `SomeRadNameSpace.trigger`. This method takes care of distributing the events. There would also need to be a method that allows code to subscribe to events. jQuery already has some functionality for [this](http://api.jquery.com/category/events/) out of the box. Another library I like using for event management is [Backbone.js](http://backbonejs.org/). Both provide efficient solutions for dealing with events, however, they don't provide a lot of visibility on what is subscribing or when events occur. I find that adding some simple event logging helps a ton.

```coffeescript
SomeRadNameSpace.bind = (ev, callback, context) ->
  logger.info "SomeRadNameSpace.bind: #{ev};"
  Backbone.Events.bind(ev, callback, context)

SomeRadNameSpace.trigger = (notification, data) ->
  logger.info "SomeRadNameSpace.trigger: #{notification}; typeof data == #{typeof data};"
  Backbone.Events.trigger notification, data

logger = ((methods)->
  _.each ['log', 'info', 'debug', 'warn', 'error'], (method)->
    methods[method] = (message)->
      if debug && window.console
        window.console[if window.console[method] then method else 'log'] message
  methods
)({})
```

The `bind` and `trigger` methods are adaptors for the Backbone.js event methods. We can now easily add some custom logging so we always know what's going on. In addition (off topic), our application code stays decoupled from Backbone.js. If there's ever a need to phase out Backbone.js or Backbone.js deprecates or renames their event methods, refactoring your codebase is as simple as possible.

Adding event handlers can now be done like this:

```coffeescript
(->

  initialize: ->
    SomeRadNameSpace.bind 'authenticate', @authenticate, this
    SomeRadNameSpace.bind 'flash_message', @flash_message, this
    SomeRadNameSpace.bind 'something_relevant', @do_something_relevant, this

  authenticate: (data = {})->
    # do stuff

  flash_message: (data = {})->
    # do stuff

  do_something_relevant: (data = {})->
    # do stuff

)().initialize()
```

I think this is a pretty solid convention for managing events. I mostly emphasized its use with ajax events, but it can easily accomodate any others needed to be dealt with. To me the highlights are:

* Lots of logging (this should be disabled in production environments). Makes it easy to keep an eye on the amount of communication going on.
* The response objects are managed in one place - the `ClientSideEvent` module. I find this to be much tidier than having arbitrary data structures scattered among controllers.
* There's no need to use jquery and jquery-ujs ajax events all over an application.
