require_relative 'application_controller'

module Amlapp
  class OrdersController < ApplicationController
    include Pagination

    authorize_actions_for AML::Order

    def index
      render :index, locals: { orders: paginate(q.result.ordered), workflow_state: workflow_state }
    end

    def new
      render :new, locals: { order: AML::Order.new(permitted_params) }
    end

    def create
      redirect_to order_path(AML::Order.create!(permitted_params))
    rescue ActiveRecord::RecordInvalid => e
      flash.now.alert = e.message
      render :new, locals: { order: e.record, client_id: e.record.client.id }
    end

    def edit
      authorize_action_for order
      render :edit, locals: { order: order }
    end

    def show
      authorize_action_for order
      render :show, locals: { order: order }
    end

    def done
      authorize_action_for order
      order.done!
      flash.notice = 'Заявка отмечена как загруженная'
      redirect_to order_path(order)
    end

    def in_process
      authorize_action_for order
      order.process! operator: current_user
      flash.notice = 'Заявка принята в обработку'
      redirect_to order_path(order)
    end

    def accept
      authorize_action_for order
      order.accept!
      flash.notice = 'Заявка принята'

      redirect_to order_path(order)
    rescue Workflow::TransitionHalted => e
      flash.now.alert = e.message
      render :show, locals: { order: order }
    end

    def reject
      authorize_action_for order
      order.reject! reject_reason: permitted_params[:reject_reason].presence || 'Причина не указана'
      flash.notice = 'Заявка отклонена'
      redirect_to order_path(order)
    rescue Workflow::TransitionHalted => e
      flash.now.alert = e.message
      render :edit, locals: { order: order }
    end

    def cancel
      authorize_action_for order
      order.cancel!
      flash.notice = 'Обработка заявки приостановлена'
      redirect_to order_path(order)
    end

    private

    DEFAULT_WORKFLOW_STATE = :pending

    def workflow_state
      params[:workflow_state] || DEFAULT_WORKFLOW_STATE
    end

    def orders
      return AML::Order.where(workflow_state: workflow_state) if current_user.administrator?
      return AML::Order.where(workflow_state: workflow_state) if workflow_state == 'pending'

      AML::Order.where(workflow_state: workflow_state, operator_id: current_user.id)
    end

    def order
      @order ||= AML::Order.find params[:id]
    end

    def permitted_params
      params.fetch(:order, {}).permit(:first_name, :surname, :patronymic, :birth_date, :client_id, :workflow_state, :reject_reason)
    end

    def q
      @q ||= orders.ransack params.fetch(:q, {}).permit!
    end
  end
end
