FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    given_name { Faker::Name.first_name }
    family_name { Faker::Name.last_name }
    gender { [nil, 'male', 'female', 'other', 'unspecified'].sample }
    password { Faker::Internet.password }

    factory :admin do
      role { 'ADMIN' }
    end
  end
end
