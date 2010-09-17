require 'benchmark'

namespace :bench do

  task :categ_balance => :environment do
    puts "Testing with #{Transaction.count} transactions"
    Benchmark.bmbm(7) do |x|
      x.report("with memoize") { Category.roots.first.mem_alt_balance }
      x.report("without memoize through categs") { Category.roots.first.alt_balance }
      x.report("without memoize through trans") { Category.roots.first.balance }
    end
  end

  task :for_month => :environment do
    ini = Time.zone.now.beginning_of_month
    fin = Time.zone.now.end_of_month
    puts "Testing with #{Transaction.count} transactions"
    Benchmark.bmbm(7) do |x|
      x.report("made_on between :ini and :end")   { Transaction.all(:conditions => ["made_on between :ini and :end",
                                                                            {:ini => ini,
                                                                             :end => fin}]) }
      x.report(":ini < made_on and made_on < :end") { Transaction.all(:conditions => [":ini < made_on and made_on < :end",
                                                                            {:ini => ini,
                                                                             :end => fin}]) }
      x.report("month(made_on)=:month and year(made_on)=:year")  { Transaction.all(:conditions => ["YEAR(made_on)=:year and month(made_on)=:month",
                                                                                        {:year => ini.year,
                                                                                         :month => ini.month}]) }
    end
  end

  task :for_year => :environment do
    ini = Time.zone.now.beginning_of_year
    fin = Time.zone.now.end_of_year
    puts "Testing with #{Transaction.count} transactions"
    Benchmark.bmbm(7) do |x|
      x.report("made_on between :ini and :end")   { Transaction.all(:conditions => ["made_on between :ini and :end",
                                                                            {:ini => ini,
                                                                             :end => fin}]) }
      x.report(":ini < made_on and made_on < :end") { Transaction.all(:conditions => [":ini < made_on and made_on < :end",
                                                                            {:ini => ini,
                                                                             :end => fin}]) }
      x.report("year(made_on)=:year")  { Transaction.all(:conditions => ["YEAR(made_on)=:year",
                                                                            {:year => ini.year}]) }
    end
  end
end

