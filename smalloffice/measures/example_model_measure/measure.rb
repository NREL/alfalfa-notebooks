require 'alfalfa'

class ExampleModelMeasure < OpenStudio::Measure::ModelMeasure

  include OpenStudio::Alfalfa::OpenStudioMixin

  # human readable name
  def name
    return 'Example Model Measure'
  end

  # human readable description
  def description
    return 'An Example Measure to act as a starting point for a tutorial'
  end

  # human readable description of modeling approach
  def modeler_description
    return 'An Example Measure to act as a starting point for a tutorial'
  end

  # define the arguments that the user will input
  def arguments(model)
    OpenStudio::Measure::OSArgumentVector.new
  end

  # define what happens when the measure is run
  def run(model, runner, user_arguments)
    super(model, runner, user_arguments)  # Do **NOT** remove this line

    # use the built-in error checking
    if !runner.validateUserArguments(arguments(model), user_arguments)
      return false
    end

    return true
  end
end

# register the measure to be used by the application
ExampleModelMeasure.new.registerWithApplication
