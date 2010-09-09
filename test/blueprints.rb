require 'machinist/active_record'
require 'sham'

Sham.define do
  name { Faker::Name.first_name }
  description { Faker::Lorem.paragraph }
  date { Date.civil((1990...2009).to_a.rand, (1..12).to_a.rand, (1..28).to_a.rand) }
end

PadmaToken.blueprint do
  user  { User.find_or_create_by_drc_user("homer") }
  token { "asdfasfdasdfasdf" }
  secret { "asdfasdfasdf" }
  type { "PadmaToken" }
end

School.blueprint do
  name
end
Sham.school { School.make }

User.blueprint do
  drc_user
  school  { School.first || School.make }
end

Account.blueprint do
  name
  cents     { 0 }
  currency  { "ARS" }
  school    { School.first || School.make }
end
Sham.account { Account.make }

Transaction.blueprint do
  account
  currency  { account.currency }
  cents     { 10 }
  description
  user      { User.find_or_create_by_drc_user("homer") }
  made_on   { Sham.date }
  type      { nil }
end
Transaction.blueprint(:income) { type { "Income" } }
Transaction.blueprint(:expense) { type { "Expense" }}
