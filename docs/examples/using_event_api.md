# Using Event API

## Overview of RabbitMQ Naming Convention

AppLogic follows the naming conventions defined in Peatio. See Peatio event API docs [here](https://github.com/rubykube/peatio/blob/28a5d191df2273e0feeaebcec23d08dc442b7fb2/docs/specs/event_api.md).

AppLogic submits all events into three exchanges depending on event category (read next).

The exchange name consists of three parts:

  1) application name, like `applogic`, `peatio`, `barong`.

  2) fixed keyword `events`.

  3) category of event, like `system` (generic system event), `model` (the attributes of some record were updated), `market` (trading events).

The routing key looks like `transaction.success`.

The event name matches the routing key but with event category appended at the beginning, like `model.transaction.success`.

## Creating event consumer

Event consumer should respond to `call(event)` and be defined at `app/consumers`.

Consumer class name must be defined as:

```
[Application name]::[Event category]::[Event name]Consumer
```

Example (at `app/consumers/barong/model/account_created_consumer.rb`):

```ruby
# frozen_string_literal: true

module Barong
  module Model
    class AccountCreatedConsumer
      def call(event)
        token = event[:record][:confirmation_token]
        email = event[:record][:email]
        BarongMailer.verification_email(email, token).deliver_now
      end

      class << self
        def call(event)
          new.call(event)
        end
      end
    end
  end
end

```

You can replace `Barong` with `Peatio`, update event name so you can handle events from `Peatio`.

## Configuration

You need to set new variables:

```yml
  EVENT_API_RABBITMQ_URL: ~
  EVENT_API_RABBITMQ_HOST:     localhost
  EVENT_API_RABBITMQ_PORT:     '5672'
  EVENT_API_RABBITMQ_USERNAME: guest
  EVENT_API_RABBITMQ_PASSWORD: guest

  BARONG_EVENT_API_JWT_PUBLIC_KEY:        ~     # Mandatory.
  BARONG_EVENT_API_JWT_ALGORITHM:         RS256 # JWT signing algorithm (mandatory).
  BARONG_EVENT_API_JWT_ISSUER:            ~     # JWT issuer name (optional).
  BARONG_EVENT_API_JWT_AUDIENCE:          ~     # Optional.
  BARONG_EVENT_API_JWT_SUBJECT:           ~     # Optional.
  BARONG_EVENT_API_JWT_DEFAULT_LEEWAY:    ~     # Seconds (optional).
  BARONG_EVENT_API_JWT_ISSUED_AT_LEEWAY:  ~     # Seconds (optional).
  BARONG_EVENT_API_JWT_EXPIRATION_LEEWAY: ~     # Seconds (optional).
  BARONG_EVENT_API_JWT_NOT_BEFORE_LEEWAY: ~     # Seconds (optional).
```

## Running event listener

The event listener is defined as Rake task.

Use the next command to run event listener:

```sh
EVENT_API_APPLICATION=barong EVENT_API_EVENT_CATEGORY=model EVENT_API_EVENT_NAME=account.created bundle exec rake event_api_listener
```
