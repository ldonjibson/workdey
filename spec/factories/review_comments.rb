FactoryGirl.define do
  factory :review_comment do
    body "This is a comment"
    review_id 1
    user_id 2
  end
end
