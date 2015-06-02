# encoding: utf-8

require_relative './user_presenter'

module Carto
  module Api
    class OrganizationsController < ::Api::ApplicationController
      include PagedSearcher

      ssl_required :users

      before_filter :load_organization

      def users
        page, per_page, order = page_per_page_order_params(50, :username)
        query = params[:q]
        users_query = @organization.users.offset(page - 1).limit(per_page).order(order)
        users_query = users_query.where('(username like ? or email like ?)', "%#{query}%", "#{query}") if query

        render_jsonp({ users: users_query.map { |u|
          Carto::Api::UserPresenter.new(u).to_poro
        } })
      end

      def load_organization
        @organization = Carto::Organization.where(id: params[:id]).first
        render_jsonp({}, 401) and return if @organization.nil? || !@organization.is_owner_user?(current_user)
      end

    end
  end
end
