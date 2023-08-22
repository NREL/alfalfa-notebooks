require 'alfalfa'

class ExampleEPMeasure < OpenStudio::Measure::EnergyPlusMeasure

  include OpenStudio::Alfalfa::EnergyPlusMixin

  def name
    "Example EnergyPlus Measure"
  end

  def description
    "An Example Measure to act as a starting point for a tutorial"
  end

  def modeler_description
    "An Example Measure to act as a starting point for a tutorial"
  end

  def arguments(model)
    OpenStudio::Measure::OSArgumentVector.new
  end

  def run(workspace, runner, user_arguments)
    super(workspace, runner, user_arguments)

    # Get a list of all of the heating coils in the model of type Coil:Heating:DX:SingleSpeed
    heating_coils = workspace.getObjectsByType('Coil:Heating:DX:SingleSpeed'.to_IddObjectType)

    # Iterate through each heating coil in the list
    heating_coils.each do |heating_coil|
      # Get the name of the component, which is needed to refer to it
      name = heating_coil.name.get

      # Create an output variable which is connected to the 'Heating Coil Electricity Rate' of the heating coil
      heating_electricity = create_output_variable(name, 'Heating Coil Electricity Rate')

      # Set the name that will be displayed in Alfalfa to '<coil_name> Heating Electricity'
      heating_electricity.display_name = "#{name} Heating Electricity"

      # Tell Alfalfa that you would like to the output variable to be exposed. Without this line the output will not show up
      register_output(heating_electricity)

    end

    # Create an string for the name of the input variable.
    # create_ems_str takes any string and makes it a valid string that can be used in energyplus
    input_variable_ems_name = create_ems_str('Example Variable')

    # Create an external interface variable which is used as an input
    input_variable = create_external_variable(input_variable_ems_name)

    # Set the display name to 'Example Variable' this is how we'll find it in the site
    input_variable.display_name = 'Example Variable'

    # Tell Alfalfa that we want this variable to be exposed
    register_input(input_variable)

    # Create an output which listens to the value of the input variable
    output_variable = create_ems_output_variable('Example Variable Echo', input_variable_ems_name)

    # Set the output as the echo of the input.
    input_variable.echo = output_variable

    # Register the output with Alfalfa
    register_output(output_variable)

    # ACTUATOR FOR OUTDOOR AIR SYSTEM NODE DRYBULB TEMPERATURE

    # The actuator must be attached to the model's outdoor air node, so here we get that object
    outdoor_air_node = workspace.getObjectsByType('OutdoorAir:Node'.to_IddObjectType)[0]

    # We need the name of the node in order to attach to it
    outdoor_air_node_name = outdoor_air_node.name.get

    # Create the actuator
    outdoor_air_temp_actuator = create_actuator(create_ems_str('Outdoor Air Temperature'), # EMS name of the input to create
                                                outdoor_air_node_name, # Component to actuate
                                                'Outdoor Air System Node', # Component type
                                                'Drybulb Temperature', # Control Type
                                                true) # Set up actuator for external control

      runner.registerFinalCondition("Done")


    # Register the actuator
    register_input(outdoor_air_temp_actuator)

    # Create the output variable for the outdoor air node's temperature
    outdoor_air_temp = create_output_variable(outdoor_air_node_name, 'System Node Temperature')

    # Set this variable as the echo for our point
    outdoor_air_temp_actuator.echo = outdoor_air_temp

    # ACTUATOR FOR OUTDOOR AIR DRYBULB TEMPERATURE

    # The actuator must be attached to the model's surfaces so here we get that object
    surface = workspace.getObjectsByType('BuildingSurface:Detailed'.to_IddObjectType)[0]

    # We need the name of the surface in order to attach to it
    surface_name = surface.name.get

    # # Create the actuator
    outdoor_air_drybulb_temp_actuator = create_actuator(create_ems_str('Outdoor Air Drybulb Temperature'), # EMS name of the input to create
                                                 surface_name, # Component to actuate
                                                 'Surface', # Component type
                                                 'Outdoor Air Drybulb Temperature', # Control Type
                                                 true) # Set up actuator for external control



     # Register the actuator
    register_input(outdoor_air_drybulb_temp_actuator)

    # Create the output variable for the surface's outdoor air drybulb temperature
    outdoor_air_drybulb_temp = create_output_variable(outdoor_air_node_name, 'System Node Temperature')

    # Set this variable as the echo for our point
    outdoor_air_temp_actuator.echo = outdoor_air_temp




    # use the built-in error checking
    if !runner.validateUserArguments(arguments(workspace), user_arguments)
      return false
    end

    report_inputs_outputs # add this line

    runner.registerFinalCondition("Done")

    return true
  end
end

ExampleEPMeasure.new.registerWithApplication