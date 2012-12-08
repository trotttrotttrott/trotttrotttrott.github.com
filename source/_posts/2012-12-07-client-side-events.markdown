---
layout: post
title: "Client Side Events"
date: 2012-12-07 16:25
comments: true
categories: [javascript, coffeescript, ruby, rails, jquery, jquery-ujs]
---

Making web apps with rails and jquery/jquery-ujs is pretty fun. I especially enjoy that I can pass `:remote => true` to `:link_to` or `:form_for` and jquery-ujs gives me a beatiful baseline for creating asynchronous client/server activity. So simple, so pretty, so far. Then comes the part where I want to plumb in some custom behavior for dealing with the response.

If you continue using jquery-ujs by the book, you end up with a lot of this:
```javascript
$('#some_ujs_targeted_element').on('ajax:complete', function(event, xhr, status) {

  // do stuff...

});
```

...and that's cool.

The `ajax:complete` event is a jquery event triggered by the jquery-ujs library. At the time of writing this, there are a total of 7 published [jquery-ujs events](https://github.com/rails/jquery-ujs/wiki/ajax)...buuuut there's already 10 (native) [jquery ajax events](http://docs.jquery.com/Ajax_Events) that communicate just about the same information to an application.

{% img /images/eh.jpg eh? %}

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

So I guess I would call the jquery-ujs ajax events an abstraction of the native jquery ajax events (with the exception of [ajax:aborted](http://www.alfajango.com/blog/new-ajax-aborted-rails-jquery-ujs-callbacks/), but I don't want to get into that). That's cool, but I'm not sure it's a very useful abstraction. Maybe it could be argued that the jquery-ujs events are a bit more manageable (being that there's less of them or something). To me there's no obvious reason to use one over the other.

Another consideration to make is how to organize listeners. As a project grows, the more code there will be listening to and handling ajax events. It can get tough keeping track of what is listening and where it lives.

To recap, there are two questions I'd like to answer:

1. Which events should I listen to?
1. How do I keep track of what (or who, if you characterize code) is listening?

These are questions I've thought long and hard about and I think I have a decent solution (for some projects).

To address, _Which events should I listen to?_...it doesn't matter. The forementioned events are all really important, but they should each (if each) be listened for in 1 single place of an application. For any other part of the application to leverage these events, they should observe the observer...and that statement leads me to addressing, _How do I keep track of what is listening?_...the observer of the observer could know who's who when subscriptions and distributions are made. You are in control of this "observer of the observer" so why not `console.log` some reflection data in your development environment. Consider this:

```coffeescript
$(document).bind 'ajaxComplete', (e, xhr, options)->
  data = (->
    try
      return $.parseJSON(xhr.responseText)
    catch error
      # holy crap!
  )()
  if data.events
    $(data.events).each (i, event)->
      SomeRadNameSpace.trigger event.name, event.data # neeeeaaaat!
```

Alright, so I appologize for the sudden switch to coffeescript. Bare with me. What I'd like to emphasize is how the data variable is expected to be an object with a key called 'events' and an array as its value. That array would come directly from a controller. A slight downside to this is committing to always rendering json with a top level key called 'events'. Unless, perhaps you have a module that handles the repitition:

```ruby
# Module for constructing client-side notifications that the app's javascript knows how to handle

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

  private

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

Okay, a lot going on there. This controller could use it...

```ruby
require 'client_side_event'

class SomeController < ApplicationController

  include ClientSideEvent

  def hola
    render :json => client_side_event(
      [:authenticate, 'who are you?', '/hola'],
      [:flash_message, 'alert', 'to be or...'],
      [:some_random_notification, { :farts => 'can be humorous' }]
    )
  end
end
```

and would respond with...

```json
{
  "events": {
    "authenticate": {
      "message": "who are you?",
      "attempted_path": "/hola"
    },
    "flash_message": {
      "type": "alert",
      "message": "to be or..."
    },
    "some_random_notification": {
      "farts": "can be humorous"
    }
  }
}

```

1 library event is used, however, it is made very flexible in terms of a specific domain. The controllers dictate the events as opposed to the generic, potentially more irresponsible javascript.
