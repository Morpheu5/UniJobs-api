FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    given_name { Faker::Name.first_name }
    family_name { Faker::Name.last_name }
    password { Faker::Internet.password }

    factory :admin do
      after(:build) do |user|
        user.role = 'ADMIN'
      end
    end
  end
end
