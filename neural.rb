require 'csv'
require 'ruby-fann'

x_data = []
y_data = []
# Load data from CSV file into two arrays - one for independent variables X and one for the dependent variable Y
# Exam scores are given as floats and the admission value is given as a binary value. 1 for admitted and 0 for not admitted.
CSV.foreach("./data/admission.csv", :headers => false) do |row|
    # here we are loading exam 1 score and exam 2 score in x_data.
    # here we are loading one for the dependent variable (admission) y_data.
    x_data.push( [row[0].to_f, row[1].to_f])
    y_data.push( [row[2].to_i] )
end

# Now we divide the data into training data and testing data. We have allocated 20% of data
# for testing and 80% for training. We split the data like this:
# Divide data into a training set and test set
test_size_percentage = 20.0
test_set_size = x_data.size * (test_size_percentage/100.to_f)

# resion we even have to do this is because the index starts at 0
test_x_data = x_data[0 .. (test_set_size-1)]
test_y_data = y_data[0 .. (test_set_size-1)]

training_x_data = x_data[test_set_size .. x_data.size]
training_y_data = y_data[test_set_size .. y_data.size]

# With our data ready to go we can setup our training data model. Ruby-fann
# requires our training data to be loaded into a TrainData class like this:
# train = RubyFann::TrainData.new( :inputs => training_x_data, :desired_outputs => training_y_data);
train = RubyFann::TrainData.new( :inputs=> training_x_data, :desired_outputs=>training_y_data );
# Even if you have one output node the outputs have to be a two-dimensional array
# Here is the Neural Network Model
model = RubyFann::Standard.new(
    num_inputs: 2,
    hidden_neurons: [6],
    num_outputs: 1
);

# 5000 max_epochs, 500 errors between reports and 0.01 desired mean-squared-error
# Better explanation
# The model is trained for 5000 epochs, for every 500 epochs we ask FANN to output our error and
# allow the training process to stop if the error drops below 0.01.
model.train_on_data(train, 5000, 500, 0.01)

# The error should keep decreasing as we train the model.
# If the error does not decrease we need to stop and reevaluate our network architecture
# With our model we can start running predictions
# Lets predict whether a student with a exam 1 score 45 and an exam 2 score 85 will get admitted:
prediction = model.run( [45, 85] )
# Round the output to get the prediction
# mapping this we need two curly braces not one
puts "Algorithm predicted class: #{prediction.map{ |e| e.round }}"

# We need to round the output nodes
# Now to determine accuracy we run a prediction on all of our test data
# one-by-one, and then compare it with the actual admission data like this:
predicted = []
test_x_data.each do |params|
    predicted.push( model.run(params).map { |e| e.round }
)
end


correct = predicted.collect.with_index { |e,i| (e == test_y_data[i]) ? 1 : 0 }.inject{ |sum, e| sum+e }

puts "Accuracy: #{((correct.to_f / test_set_size) * 100).round(2)}% - test set of size #{test_size_percentage}%"

