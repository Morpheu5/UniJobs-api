# frozen_string_literal: true

module Api
  module V1
    class SocialPostsController < ApplicationController
      before_action :set_social_post, only: %i[show update destroy]

      # GET /social_posts
      def index
        @social_posts = SocialPost.all

        render json: @social_posts
      end

      # GET /social_posts/1
      def show
        render json: @social_post
      end

      # POST /social_posts
      def create
        @social_post = SocialPost.new(social_post_params)

        if @social_post.save
          render json: @social_post, status: :created, location: @social_post
        else
          render json: @social_post.errors, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /social_posts/1
      def update
        if @social_post.update(social_post_params)
          render json: @social_post
        else
          render json: @social_post.errors, status: :unprocessable_entity
        end
      end

      # DELETE /social_posts/1
      def destroy
        @social_post.destroy
      end

      def cycle
        posts = SocialPost.joins(:content).merge(Content.order(created_at: :asc))
        return if posts.empty?

        posts = posts.filter { |p| p[:status].values.any? 'NEW' }
        twitter_post = twitter(posts)

        render json: {
          twitter: twitter_post
        }.compact
      end

      private

      def twitter(posts)
        status = 'DONE'
        messages = ''
        twitter_post = posts.filter { |p| p[:status]['twitter'] == 'NEW' }[0]
        return if twitter_post.nil?

        content = twitter_post.content
        if content.nil?
          messages += "Content was nil\n"
          status = 'ERROR'
        else
          organization = content.organization
          tweet_it = content.title['it'].truncate(160, separator: ' ', omission: '…') +
                     '#' + organization.short_name + '#UniJobs #ricerca #lavoro #Italia 🇮🇹 #EU 🇪🇺 #AcademicTwitter'
          tweet_en = content.title['en'].truncate(160, separator: ' ', omission: '…') +
                     '#' + organization.short_name + '#UniJobs #research #jobs #Italy 🇮🇹 #EU 🇪🇺 #AcademicTwitter'

          client = Twitter::REST::Client.new do |config|
            config.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
            config.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
            config.access_token        = ENV['TWITTER_ACCESS_TOKEN']
            config.access_token_secret = ENV['TWITTER_ACCESS_TOKEN_SECRET']
          end

          begin
            client.user
          rescue Twitter::Error => e
            Rails.logger.fatal "Could not access the Twitter the user. Possible misconfiguration?\n => Error: #{e.message}"
            return
          end

          begin
            client.update(tweet_it)
            client.update(tweet_en)
          rescue Twitter::Error => e
            messages += e.inspect
            status = 'ERROR'
          end
        end

        twitter_post[:messages] += messages
        twitter_post[:status]['twitter'] = status
        twitter_post.save
        twitter_post
      end

      # Use callbacks to share common setup or constraints between actions.
      def set_social_post
        @social_post = SocialPost.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def social_post_params
        params.require(:social_post).permit(:content_id, :status, :messages)
      end
    end
  end
end
