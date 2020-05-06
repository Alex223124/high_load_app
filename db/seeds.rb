Evaluation.delete_all
Match.delete_all
Post.delete_all
Rating.delete_all
Statistics.delete_all
Persona::Session.delete_all
Persona::User.delete_all
Settings::Caching.delete_all



# in seconds
top_posts_caching_time = 600
# object count
top_posts_limit = 210000

Settings::Caching.create!(top_posts_caching_time: top_posts_caching_time, top_posts_limit: top_posts_limit)


def value
  [1,2,3,4,5].sample
end

posts_amount = 1000000
@evaluations_amount = 1000000
matches_amount = 50000

def create_post(n, evaluation: true)
  resp = Faraday.post('http://localhost:3000/api/v1/posts') do |req|
    req.headers['Content-Type'] = 'application/json'
    req.body = { post: {title: "test_post_title#{n}",
                        content: "test content",
                        ip:  "222.444.111.#{n}",
                        login: "test_login_#{n}" } }.to_json

    if n < @evaluations_amount && evaluation
      create_evaluation(n)
    end
  end
end

def create_evaluation(n)
  resp = Faraday.post('http://localhost:3000/api/v1/evaluations') do |req|
    req.headers['Content-Type'] = 'application/json'
    req.body = { evaluation: {post_id: "#{n + 1}",
                              value: value} }.to_json
  end
end


posts_amount.times do |n|
  puts "Iteration nubmer #{n}"
  create_post(n)
  if n < matches_amount
    create_post(n, evaluation: false)
  end

  # uncomment it to get stats about queries for these endpoints
  #Faraday.get("http://localhost:3000/api/v1/top_posts/#{n}")
  #Faraday.get("http://localhost:3000/api/v1/matches")

end


#require 'net/http'
#
## Our sample set of currencies
#currencies = ['ARS','AUD','CAD','CNY','DEM','EUR','GBP','HKD','ILS','INR','USD','XAG','XAU']
## Create an array to keep track of threads
#threads = []
#
#currencies.each do |currency|
#  # Keep track of the child processes as you spawn them
#  threads << Thread.new do
#    puts Net::HTTP.get("download.finance.yahoo.com","/d/quotes.csv?e=.csv&amp;f=sl1d1t1&amp;s=USD#{currency}=X")
#  end
#end
## Join on the child processes to allow them to finish
#threads.each do |thread|
#  thread.join
#end
#puts "DONE!"

#@threads = []
#
#100.times do |a|
#  @threads << Thread.new do
#    puts a
#    Faraday.get("http://localhost:3000/api/v1/top_posts/10000")
#  end
#end
#
#@threads.each do |thread|
#  thread.join
#end
#
#puts "DONE!"
#

#require 'thread'
#require 'monitor'
##require 'net/http'
#
## Our sample set of currencies
##currencies = ['ARS','AUD','CAD','CNY','DEM','EUR','GBP','HKD','ILS','INR','USD','XAG','XAU']
#
## Set a finite number of simultaneous worker threads that can run
#thread_count = 5
#
## Create an array to keep track of threads
#threads = Array.new(thread_count)
#
## Create a work queue for the producer to give work to the consumer
#work_queue = SizedQueue.new(thread_count)
#
## Add a monitor so we can notify when a thread finishes and we can schedule a new one
#threads.extend(MonitorMixin)
#
## Add a condition variable on the monitored array to tell the consumer to check the thread array
#threads_available = threads.new_cond
#
## Add a variable to tell the consumer that we are done producing work
#sysexit = false
#
#consumer_thread = Thread.new do
#  loop do
#    # Stop looping when the producer is finished producing work
#    break if sysexit &amp; work_queue.length == 0
#    found_index = nil
#
#    # The MonitorMixin requires us to obtain a lock on the threads array in case
#    # a different thread may try to make changes to it.
#    threads.synchronize do
#      # First, wait on an available spot in the threads array.  This fires every
#      # time a signal is sent to the "threads_available" variable
#      threads_available.wait_while do
#        threads.select { |thread| thread.nil? || thread.status == false  ||
#            thread["finished"].nil? == false}.length == 0
#      end
#      # Once an available spot is found, get the index of that spot so we may
#      # use it for the new thread
#      found_index = threads.rindex { |thread| thread.nil? || thread.status == false ||
#          thread["finished"].nil? == false }
#    end
#
#    # Get a new unit of work from the work queue
#    currency = work_queue.pop
#
#    # Pass the currency variable to the new thread so it can use it as a parameter to go
#    # get the exchange rates
#    threads[found_index] = Thread.new(currency) do
#      puts Faraday.get("http://localhost:3000/api/v1/top_posts/10000")
#      # When this thread is finished, mark it as such so the consumer knows it is a
#      # free spot in the array.
#      Thread.current["finished"] = true
#
#      # Tell the consumer to check the thread array
#      threads.synchronize do
#        threads_available.signal
#      end
#    end
#  end
#end
#
#producer_thread = Thread.new do
#  # For each currency we need to download...
#  1000000.times do |request|
#  #currencies.each do |currency|
#    # Put the currency on the work queue
#    puts request
#    work_queue << request
#
#    # Tell the consumer to check the thread array so it can attempt to schedule the
#    # next job if a free spot exists.
#    threads.synchronize do
#      threads_available.signal
#    end
#  end
#  # Tell the consumer that we are finished downloading currencies
#  sysexit = true
#end
#
## Join on both the producer and consumer threads so the main thread doesn't exit while
## they are doing work.
#producer_thread.join
#consumer_thread.join
#
## Join on the child processes to allow them to finish (if any are left)
#threads.each do |thread|
#  thread.join unless thread.nil?
#end
#puts "DONE!"