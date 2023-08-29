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

    ## ACTUATOR FOR OUTDOOR AIR SYSTEM NODE DRYBULB TEMPERATURE

    # The actuator must be attached to the model's outdoor air node, so here we get that object
    outdoor_air_nodes = workspace.getObjectsByType('OutdoorAir:Node'.to_IddObjectType)

    # Iterate
    outdoor_air_nodes.each do |outdoor_air_node|

      # We need the name of the node in order to attach to it
      outdoor_air_node_name = outdoor_air_node.name.get

      # Create the actuator
      outdoor_air_temp_actuator = create_actuator(create_ems_str('Outdoor Air Temperature'), # EMS name of the input to create
                                            outdoor_air_node_name, # Component to actuate
                                            'Outdoor Air System Node', # Component type
                                            'Drybulb Temperature', # Control Type
                                            true) # Set up actuator for external control

      # Register the actuator
      register_input(outdoor_air_temp_actuator)

      # Create the output variable for the outdoor air node's temperature
      outdoor_air_temp = create_output_variable(outdoor_air_node_name, 'System Node Temperature')

      # Set this variable as the echo for our point
      outdoor_air_temp_actuator.echo = outdoor_air_temp
    end


    ## ACTUATOR FOR OUTDOOR AIR DRYBULB AND WETBULB TEMPERATURE FOR SURFACE

    # The actuator must be attached to the model's surfaces so here we get that object
    surfaces = workspace.getObjectsByType('BuildingSurface:Detailed'.to_IddObjectType)

    surfaces.each do |surface|

      # We need the name of the surface in order to attach to it
      surface_name = surface.name.get

      # # Create the actuator
      outdoor_air_drybulb_temp_actuator = create_actuator(create_ems_str('Outdoor Air Drybulb Temperature'), # EMS name of the input to create
                                                  surface_name, # Component to actuate
                                                  'Surface', # Component type
                                                  'Outdoor Air Drybulb Temperature', # Control Type
                                                  true) # Set up actuator for external control


      outdoor_air_wetbulb_temp_actuator = create_actuator(create_ems_str('Outdoor Air Wetbulb Temperature'), # EMS name of the input to create
                                                  surface_name, # Component to actuate
                                                  'Surface', # Component type
                                                  'Outdoor Air Wetbulb Temperature', # Control Type
                                                  true) # Set up actuator for external control


      # Register the actuator
      register_input(outdoor_air_drybulb_temp_actuator)
      register_input(outdoor_air_wetbulb_temp_actuator)


      # Create the output variable for the surface's outdoor air drybulb and wetbulb temperature
      outdoor_air_drybulb_temp = create_output_variable(surface_name, 'Outdoor Air Drybulb Temperature')
      outdoor_air_wetbulb_temp = create_output_variable(surface_name, 'Outdoor Air Wetbulb Temperature')

      # Set this variable as the echo for our point
      outdoor_air_drybulb_temp_actuator.echo = outdoor_air_drybulb_temp
      outdoor_air_wetbulb_temp_actuator.echo = outdoor_air_wetbulb_temp


    end



    ## ACTUATOR FOR OUTDOOR AIR DRYBULB AND WETBULB TEMPERATURE FOR ZONE

    # The actuator must be attached to the model's zone so here we get that object
    zones = workspace.getObjectsByType('Zone'.to_IddObjectType)

    zones.each do |zone|
      # We need the name of the surface in order to attach to it
      zone_name = zone.name.get

      # # Create the actuator
      outdoor_air_drybulb_temp_zone_actuator = create_actuator(create_ems_str('Outdoor Air Drybulb Temperature'), # EMS name of the input to create
                                                  zone_name, # Component to actuate
                                                  'Zone', # Component type
                                                  'Outdoor Air Drybulb Temperature', # Control Type
                                                  true) # Set up actuator for external control


      outdoor_air_wetbulb_temp_zone_actuator = create_actuator(create_ems_str('Outdoor Air Wetbulb Temperature'), # EMS name of the input to create
                                                    zone_name, # Component to actuate
                                                    'Zone', # Component type
                                                    'Outdoor Air Wetbulb Temperature', # Control Type
                                                    true) # Set up actuator for external control


      # Register the actuator
      register_input(outdoor_air_drybulb_temp_zone_actuator)
      register_input(outdoor_air_wetbulb_temp_zone_actuator)


      # Create the output variable for the surface's outdoor air drybulb and wetbulb temperature
      outdoor_air_drybulb_zone_temp = create_output_variable(zone_name, 'Outdoor Air Drybulb Temperature')
      outdoor_air_wetbulb_zone_temp = create_output_variable(zone_name, 'Outdoor Air Wetbulb Temperature')

      # Set this variable as the echo for our point
      outdoor_air_drybulb_temp_zone_actuator.echo = outdoor_air_drybulb_zone_temp
      outdoor_air_wetbulb_temp_zone_actuator.echo = outdoor_air_wetbulb_zone_temp

    end


    # ## ACTUATOR FOR ZONE DESIGN HEATING AND COOLING AIR MASS FLOW RATE

    # The actuator must be attached to the model's zone so here we get that object
    sizing_zones = workspace.getObjectsByType('Sizing:Zone'.to_IddObjectType)

    sizing_zones.each do |sizing_zone|

      # We need the name of the zone in order to attach to it
      sizing_zone_name = sizing_zone.getString(0)

      # # Create the actuator
      heating_mass_flow_actuator = create_actuator(create_ems_str('Zone Design Heating Air Mass Flow Rate'), # EMS name of the input to create
                                                  sizing_zone_name, # Component to actuate
                                                  'Sizing:Zone', # Component type
                                                  'Zone Design Heating Air Mass Flow Rate', # Control Type
                                                  true) # Set up actuator for external control


      cooling_mass_flow_actuator = create_actuator(create_ems_str('Zone Design Cooling Air Mass Flow Rate'), # EMS name of the input to create
                                                    sizing_zone_name, # Component to actuate
                                                    'Sizing:Zone', # Component type
                                                    'Zone Design Cooling Air Mass Flow Rate', # Control Type
                                                    true) # Set up actuator for external control


      # Register the actuator
      register_input(heating_mass_flow_actuator)
      register_input(cooling_mass_flow_actuator)


      # Create the output variable
      heating_mass_flow = create_output_variable(sizing_zone_name, 'Zone Design Heating Air Mass Flow Rate')
      cooling_mass_flow = create_output_variable(sizing_zone_name, 'Zone Design Cooling Air Mass Flow Rate')

      # Set this variable as the echo for our point
      heating_mass_flow_actuator.echo = heating_mass_flow
      cooling_mass_flow_actuator.echo = cooling_mass_flow

    end

    # ## ACTUATOR FOR FAN AIR MASS FLOW RATE

    # The actuator must be attached to EP object
    fans = workspace.getObjectsByType('Fan:VariableVolume'.to_IddObjectType)

    fans.each do |fan|

      # We need the name of the fan in order to attach to it
      fan_name = fan.name.get[0]

      # # Create the actuator
      fan_actuator = create_actuator(create_ems_str('Fan Air Mass Flow Rate'), # EMS name of the input to create
                                                  fan_name, # Component to actuate
                                                  'Fan:VariableVolume', # Component type
                                                  'Fan Air Mass Flow Rate', # Control Type
                                                  true) # Set up actuator for external control


      # Register the actuator
      register_input(fan_actuator)

      # Create the output variable
      fan_mass_flow = create_output_variable(fan_name, 'Fan Air Mass Flow Rate')

      # Set this variable as the echo for our point
      fan_actuator.echo = fan_mass_flow

    end

    # ## ACTUATOR FOR OUTDOOR AIR CONTROLLER AIR MASS FLOW RATE

    # The actuator must be attached to EP object
    controllers = workspace.getObjectsByType('Controller:OutdoorAir'.to_IddObjectType)

    controllers.each do |controller|

      # We need the name of the fan in order to attach to it
      controller_name = controller.name.get

      # # Create the actuator
      controller_actuator = create_actuator(create_ems_str('Air Mass Flow Rate'), # EMS name of the input to create
                                                  controller_name, # Component to actuate
                                                  'Controller:OutdoorAir', # Component type
                                                  'Air Mass Flow Rate', # Control Type
                                                  true) # Set up actuator for external control


      # Register the actuator
      register_input(controller_actuator)


      # Create the output variable
      controller_mass_flow = create_output_variable(controller_name, 'Air Mass Flow Rate')

      # Set this variable as the echo for our point
      controller_actuator.echo = controller_mass_flow

    end


    # ## ACTUATOR FOR ZONE THERMOSTAT CONTROL HEATING SETPOINT

    # The actuator must be attached to EP object
    thermostats = workspace.getObjectsByType('ZoneControl:Thermostat'.to_IddObjectType)

    thermostats.each do |thermostat|

      # We need the name of the fan in order to attach to it
      thermostat_name = thermostat.name.get

      # # Create the actuator
      thermostat_actuator_heating = create_actuator(create_ems_str('Heating Setpoint'), # EMS name of the input to create
                                                  thermostat_name, # Component to actuate
                                                  'ZoneControl:Thermostat', # Component type
                                                  'Heating Setpoint', # Control Type
                                                  true) # Set up actuator for external control

      thermostat_actuator_cooling = create_actuator(create_ems_str('Cooling Setpoint'), # EMS name of the input to create
                                                    thermostat_name, # Component to actuate
                                                    'ZoneControl:Thermostat', # Component type
                                                    'Cooling Setpoint', # Control Type
                                                    true) # Set up actuator for external control

      # Register the actuator
      register_input(thermostat_actuator_heating)
      register_input(thermostat_actuator_cooling)


      # Create the output variable
      thermostat_heating_setpoint = create_output_variable(thermostat_name, 'Heating Setpoint')
      thermostat_cooling_setpoint = create_output_variable(thermostat_name, 'Cooling Setpoint')

      # Set this variable as the echo for our point
      thermostat_actuator_heating.echo = thermostat_heating_setpoint
      thermostat_actuator_cooling.echo = thermostat_cooling_setpoint

    end



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
