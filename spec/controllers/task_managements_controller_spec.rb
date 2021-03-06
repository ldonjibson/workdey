require "rails_helper"

RSpec.describe TaskManagementsController, type: :controller do
  let!(:user) { create(:user) }
  let!(:ironing) do
    create(:task_management, description: Faker::Lorem.sentence)
  end
  let!(:cleaning) do
    create(:task_management, description: Faker::Lorem.sentence)
  end
  let!(:carpentry) do
    create(:task_management, description: Faker::Lorem.sentence)
  end
  let!(:washing) do
    create(:task_management, description: Faker::Lorem.sentence)
  end

  describe "GET #index" do
    context "when no user is logged in" do
      before do
        allow_any_instance_of(ApplicationController).
          to receive(:current_user).and_return(nil)
        user.tasks_created = [ironing, cleaning]
        user.tasks_given = [carpentry, washing]
      end
      it "should have a redirect status" do
        get :index
        expect(response).to have_http_status(302)
      end
    end
    context "when a user is logged in" do
      before(:each) do
        allow_any_instance_of(ApplicationController).
          to receive(:current_user).and_return(user)
        user.tasks_created = [ironing, cleaning]
        user.tasks_given = [carpentry, washing]
      end
      it "should render the index page" do
        get :index
        expect(response).to have_http_status(:success)
        expect(response).to render_template("index")
      end
      it "assigns tasks created to tasker" do
        get :index
        expect(assigns(:tasks)).to eql user.tasks_created.to_a
      end
      it "assigns tasks given to artisan" do
        user.update_attribute(:user_type, "artisan")
        get :index
        expect(assigns(:tasks)).to eql user.tasks_given.paid_for.to_a
      end
    end
  end

  describe "#share" do
    let(:artisan) { create(:user, user_type: "artisan") }
    let(:tasker) { create(:user) }
    let(:task) do
      create(:task_management, artisan_id: artisan.id, tasker_id: tasker.id)
    end

    it "updates the shared atrribute to true" do
      expect(task.shared).to be false

      put :share, id: task.id
      expect(task.reload.shared).to be true
    end

    it "renders json success message" do
      put :share, id: task.id
      parsed_response = JSON.parse(response.body)
      expect(parsed_response["message"]).to eq "success"
    end

    it "increases the count of Notification table by creting a new "\
    "notification" do
      expect do
        put :share, id: task.id
      end.to change(Notification, :count).by 1
    end
  end
end
