FROM ruby:2.6.5

WORKDIR /root/app

COPY Gemfile .

RUN bundle

CMD ["shotgun", "--host", "0.0.0.0"]
