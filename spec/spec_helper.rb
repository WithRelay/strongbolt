ENV['RAILS_ENV'] ||= 'test'

RSpec.configure do |config|
  # rspec-expectations config goes here. You can use an alternate
  # assertion/expectation library such as wrong or the stdlib/minitest
  # assertions if you prefer.
  config.expect_with :rspec do |expectations|
    # This option will default to `true` in RSpec 4. It makes the `description`
    # and `failure_message` of custom matchers include text for helper methods
    # defined using `chain`, e.g.:
    # be_bigger_than(2).and_smaller_than(4).description
    #   # => "be bigger than 2 and smaller than 4"
    # ...rather than:
    #   # => "be bigger than 2"
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  # rspec-mocks config goes here. You can use an alternate test double
  # library (such as bogus or mocha) by changing the `mock_with` option here.
  config.mock_with :rspec do |mocks|
    # Prevents you from mocking or stubbing a method that does not exist on
    # a real object. This is generally recommended, and will default to
    # `true` in RSpec 4.
    mocks.verify_partial_doubles = false
  end
end

# The dummy application
require File.expand_path('../dummy/config/environment', __FILE__)

# require 'fixtures/application'
# require 'fixtures/controllers'

require 'strongbolt'
require 'shoulda/matchers'

require 'rspec/rails'
require 'fabrication'
require 'database_cleaner'
if Rails.version >= '5.0.0'
  require 'rails-controller-testing'
end

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

module ActionControllerTestCaseBehaviorCompatibility
  def get(action, **args)
    if Rails.version < '5.0.0'
      parameters, session, flash = self.__strongbolt_params_compatibility(args)
      super(action, parameters, session, flash)
    else
      super
    end
  end

  def post(action, **args)
    if Rails.version < '5.0.0'
      parameters, session, flash = self.__strongbolt_params_compatibility(args)
      super(action, parameters, session, flash)
    else
      super
    end
  end

  def patch(action, **args)
    if Rails.version < '5.0.0'
      parameters, session, flash = self.__strongbolt_params_compatibility(args)
      super(action, parameters, session, flash)
    else
      super
    end
  end

  def put(action, **args)
    if Rails.version <= '5.0.0'
      parameters, session, flash = self.__strongbolt_params_compatibility(args)
      super(action, parameters, session, flash)
    else
      super
    end
  end

  def delete(action, **args)
    if Rails.version < '5.0.0'
      parameters, session, flash = self.__strongbolt_params_compatibility(args)
      super(action, parameters, session, flash)
    else
      super
    end
  end

  def head(action, **args)
    if Rails.version < '5.0.0'
      parameters, session, flash = self.__strongbolt_params_compatibility(args)
      super(action, parameters, session, flash)
    else
      super
    end
  end

  def __strongbolt_params_compatibility(**args)
    parameters, session, flash = args
    parameters ||= {}
    return parameters.delete(:params), session, flash
  end
end

module ActionController::TestCase::Behavior
  prepend ActionControllerTestCaseBehaviorCompatibility
end

RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  # config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  config.include Helpers
  config.include TransactionalSpecs

  #
  # We setup and teardown the database for our tests
  #
  config.before(:suite) do
    TestsMigrations.new.migrate :up
    User.send :include, Strongbolt::UserAbilities
    DatabaseCleaner.clean_with :truncation
    DatabaseCleaner.strategy = :transaction
  end

  config.around(:each) do |spec|
    DatabaseCleaner.start
    spec.run
    DatabaseCleaner.clean
  end

  config.after(:suite) do
    TestsMigrations.new.migrate :down
  end

  Fabrication.configure do |fabrication_config|
    fabrication_config.fabricator_path = 'spec/fabricators'
    fabrication_config.path_prefix = File.expand_path('../..', __FILE__)
  end
  puts File.expand_path('../..', __FILE__)

  if Rails.version >= '5.0.0'
    [:controller, :view, :request].each do |type|
      config.include ::Rails::Controller::Testing::TestProcess, :type => type
      config.include ::Rails::Controller::Testing::TemplateAssertions, :type => type
      config.include ::Rails::Controller::Testing::Integration, :type => type
    end
  end
end
