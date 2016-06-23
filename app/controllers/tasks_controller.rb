class TasksController < ApplicationController
  def new
    @task = Task.new
  end

  def create
    task_attributes = task_params.except(:type, :skillsets).merge(
      tasker_id: current_user.id
    )
    @task = Task.new(task_attributes)
    if @task.save
      assign_to_taskee if task_params[:type] == "assign"
    else
      render "new"
    end
  end

  def view_taskee
    taskee_id = params[:taskee_id]
    @user = User.find(taskee_id)
    render(
      "partials/profile_view",
      locals: { assign: true, task_id: params[:task_id] }
    )
  end

  def assign
    Task.assign_task(params[:taskee_id], params[:task_id])
    redirect_to dashboard_path, notice: "You have assigned the task to a Taskee"
  end

  private

  def task_params
    params.require(:task).permit(
      :name,
      :price,
      :start_date,
      :end_date,
      :time,
      :location,
      :description,
      :skillsets,
      :type
    )
  end

  def assign_to_taskee
    @taskees = Skillset.get_taskees(task_params[:skillsets])
    street_address, city = task_params[:location].split(",")
    @taskees = Task.get_taskees_nearby(
      @taskees,
      street_address.strip.downcase,
      city.strip.downcase
    ) unless task_params[:location].empty?
    Task.add_skillsets_to_task(@task)
    render(
      "partials/search_result",
      locals: { task_id: @task.id, assigns: true }
    )
  end
end
