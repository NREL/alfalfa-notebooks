# *******************************************************************************
# OpenStudio(R), Copyright (c) 2008-2021, Alliance for Sustainable Energy, LLC.
# All rights reserved.
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# (1) Redistributions of source code must retain the above copyright notice,
# this list of conditions and the following disclaimer.
#
# (2) Redistributions in binary form must reproduce the above copyright notice,
# this list of conditions and the following disclaimer in the documentation
# and/or other materials provided with the distribution.
#
# (3) Neither the name of the copyright holder nor the names of any contributors
# may be used to endorse or promote products derived from this software without
# specific prior written permission from the respective party.
#
# (4) Other than as required in clauses (1) and (2), distributions in any form
# of modifications or other derivative works may not use the "OpenStudio"
# trademark, "OS", "os", or any other confusingly similar designation without
# specific prior written permission from Alliance for Sustainable Energy, LLC.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDER(S) AND ANY CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
# THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER(S), ANY CONTRIBUTORS, THE
# UNITED STATES GOVERNMENT, OR THE UNITED STATES DEPARTMENT OF ENERGY, NOR ANY OF
# THEIR EMPLOYEES, BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT
# OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
# STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# *******************************************************************************

# start the measure
class AlfalfaVariables < OpenStudio::Measure::ModelMeasure

  # human readable name
  def name
    return 'Alfalfa Variables'
  end

  # human readable description
  def description
    return 'Add custom variables for Alfalfa'
  end

  # human readable description of modeling approach
  def modeler_description
    return 'Add EMS global variables required by Alfalfa'
  end

  # define the arguments that the user will input
  def arguments(model)
    args = OpenStudio::Measure::OSArgumentVector.new
    return args
  end

  def create_input(model, name, freq)
    # the purpose of this function is to create an Alfalfa input that is accessible via python plugins
    global = OpenStudio::Model::EnergyManagementSystemGlobalVariable.new(model, name)
    global.setExportToBCVTB(true)
    # the global variable's value must be sent to output an variable so that python programs can read it, an Ouput:Variable object is created, but this is "input" to the simulation, from Alfalfa clients
    global_ems_output = OpenStudio::Model::EnergyManagementSystemOutputVariable.new(model, global)
    global_ems_output.setName(name + "_EMS_Value")
    global_ems_output.setUpdateFrequency("SystemTimestep")
    # request the custom EMS output var created in the previous step
    global_output = OpenStudio::Model::OutputVariable.new(global_ems_output.nameString(), model)
    global_output.setName(name + "_Value")
    global_output.setReportingFrequency(freq)
    global_output.setKeyValue("EMS")
    # setting exportToBCVTB to true is optional, and will result in the output variable showing up in the Alfalfa api, this might be useful for confirmation of the input
    global_output.setExportToBCVTB(true)
    # repeat the previous steps for an "Enable" input, this value will be 1 (instead of 0) anytime a client writes to the input via the Alfalfa API
    global_enable = OpenStudio::Model::EnergyManagementSystemGlobalVariable.new(model, name + "_Enable")
    global_enable.setExportToBCVTB(true)
    global_enable_ems_output = OpenStudio::Model::EnergyManagementSystemOutputVariable.new(model, global_enable)
    global_enable_ems_output.setName(name + "_Enable_EMS_Value")
    global_enable_ems_output.setUpdateFrequency("SystemTimestep")
    global_enable_output = OpenStudio::Model::OutputVariable.new(global_enable_ems_output.nameString(), model)
    global_enable_output.setName(name + "_Enable_Value")
    global_enable_output.setReportingFrequency(freq)
    global_enable_output.setKeyValue("EMS")
    global_enable_output.setExportToBCVTB(true)
  end

  def create_output(model, var, key, name, freq)
    new_var = OpenStudio::Model::OutputVariable.new(var, model)
    new_var.setName(name)
    new_var.setReportingFrequency(freq)
    new_var.setKeyValue(key)
    new_var.setExportToBCVTB(true)
  end

  # define what happens when the measure is run
  def run(model, runner, user_arguments)
    super(model, runner, user_arguments)
    # Alfalfa inputs - these can be set through the Alfalfa API, they will be available as OutputVariables in the simulation; use them as you will also see comments on the create_input method
    create_input(model, "Outdoor Air Wetbulb Temperature", "Timestep")
    create_input(model, "Outdoor Air Drybulb Temperature", "Timestep")
    # Alfalfa outputs
    create_output(model, "Facility Total Purchased Electricity Energy", "Whole Building", "Electric Meter", "Timestep")
    # other Output:Variables might be custom python defined output variables, you should still be able to request them here, and as long as exportToBCVTB is true they will be available via Alfalfa
    return true
  end

end

# register the measure to be used by the application
AlfalfaVariables.new.registerWithApplication
