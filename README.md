Godot plugin for acoustics calculation. Does not work at all, yet!
-----------------------------------------------------------------




Modu's domainless hybrid model for acoustics
---------------------------------------------

What is it?

Instead of rays or volumes, the wave behaviour is simulated trough moving pressure fields with one size, position, pressure, phase and velocity for each instance
This allows for simulation of both open spaces and indoor scenes while (finally) simulation diffusion. Think of the pressure fields as singular particles. 

Wouldn't this be just inefficient ray casting with lazy physics engine code?

No. This differs from typical ray based methods by really simulating wave diffusion. The fields have 3 simple laws:

=================== The laws =======================

1. All pressure fields have fixed magnitude of velocity, which should never change (speed of sound in air)
   
2. All pressure fields move apart from each other (this causes diffusion). If this is not possible, they pass trough each other and the phase and pressure is changed
 by how much the velocity vectors oppose each other.

3. Among time, pressure should decrease linearly while the size of the field/wavelength scales up (which filters off high frequencies caused by air absorption)
  
======================= * ==========================


