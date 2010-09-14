require 'machinist/active_record'
require 'sham'

Sham.define do
  description { |index| Faker::Lorem.paragraph+index.to_s }
  date        { Date.civil((1990...2009).to_a.rand, (1..12).to_a.rand, (1..28).to_a.rand) }
  padma_id    { SecureRandom.random_number(999999999999) }
end
Sham.name { |index| Faker::Name.first_name+SecureRandom.random_number(999999999999).to_s }
Sham.csv_file do
  ActionController::TestUploadedFile.new(File.dirname(__FILE__) + '/fixtures/no_accounts.csv', 'text/csv')
end

PadmaToken.blueprint do
  user  { User.find_or_create_by_drc_user("homer") }
  token { "asdfasfdasdfasdf" }
  secret { "asdfasdfasdf" }
  type { "PadmaToken" }
end

School.blueprint do
  name
  padma_id { Sham.padma_id }
end
Sham.school { School.make }

User.blueprint do
  drc_user { Sham.name }
  school  { School.first || School.make }
end

Account.blueprint do
  name      { Sham.name }
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

Import.blueprint do
  csv_file  { ActionController::TestUploadedFile.new(File.dirname(__FILE__) + '/fixtures/no_accounts.csv', 'text/csv') }
  school    { School.first || School.make }
  user      { User.find_or_create_by_drc_user("homer") }
end

ImportedRow.blueprint do
  row { SecureRandom.random_number(99999999999) }
  import  { Import.make }
  transaction { Transaction.make }
  success     { true }
end
ImportedRow.blueprint(:success){}
ImportedRow.blueprint(:failed) do
  message     { Faker::Lorem.paragraph }
  success     { false }
end