require 'machinist/active_record'
require 'sham'
require 'mocha'

Sham.define do
  description { |index| Faker::Lorem.paragraph+index.to_s }
  date        { Date.civil((1990...2009).to_a.rand, (1..12).to_a.rand, (1..28).to_a.rand) }
end
Sham.padma_id { |index| SecureRandom.random_number(999999)+index*1000000 }
Sham.name { |index| Faker::Name.first_name+SecureRandom.random_number(99999).to_s }
Sham.csv_file do
  ActionController::TestUploadedFile.new(File.dirname(__FILE__) + '/fixtures/no_accounts.csv', 'text/csv')
end

PadmaToken.blueprint do
  user  { User.find_or_create_by_drc_user("homer") }
  token { Faker::Name.first_name+(SecureRandom.random_number(99999)).to_s }
  secret { Faker::Name.first_name+(SecureRandom.random_number(99999)).to_s }
  type { "PadmaToken" }
end

Institution.blueprint do
  name
  padma_id { Sham.padma_id }
end
Sham.institution { Institution.first || Institution.make }

User.blueprint do
  drc_user { Sham.name }
  institution  { Institution.first || Institution.make }
end

Account.blueprint do
  name      { Sham.name }
  cents     { 0 }
  currency  { "ARS" }
  institution    { Institution.first || Institution.make }
end
Sham.account { Account.first || Account.make }

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
  institution    { Institution.first || Institution.make }
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

Tag.blueprint do
  name { Sham.name }
end

Category.blueprint do
  name
  institution
end

Person.blueprint do
  name        { Sham.name }
  surname     { Sham.name }
  padma_id    { Sham.padma_id }
  institution
end