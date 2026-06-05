## Sed Battleship by Red Void ##

### INIT ###

# Call stack initialization
s/^.*$/call_stack = / 

# Start message
s/$/\nlast_action_log = Place your ships firstly./ 

# Random number generator initialization
s/$/\nrng::current_state = 00000000000000000000000000000000/ 
s/$/\nrng::A = 00000000000000000000010101010110/ # A = 1366
s/$/\nrng::C = 00000000000000100100110101101001/ # C = 150889
s/$/\nrng::M = 00000000000010101110010100101001/ # M = 714025

# Luck initialization
s/$/\nluck = 00000000000000000000000000000000/

# Easter egg counter initialization
s/$/\neaster = 00000000001/ 

# Fields initialization
s/$/\nfield::player = ····································································································/
s/$/\nfield::suggestions = ····································································································/ 
s/$/\nfield::computer = ····································································································/
s/$/\nfield::player_ships = /
s/$/\nfield::computer_ships = /

# Write variables to hold space, clear pattern space
h ; s/^.*$// ; p ; s/^.*$//


### MAIN ###

:main {
  x ; s/\(call_stack = [^\n]*\)/\1,main::select_difficulty/ ; x
  b select_difficulty
  :main::select_difficulty
   
  x ; s/\(call_stack = [^\n]*\)/\1,main::set_player_ships/ ; x
  b set_player_ships
  :main::set_player_ships

  s/$/\nlast_action_log = Please wait for a while: I need to place my ships like a pro./ 
  x ; s/\(call_stack = [^\n]*\)/\1,main::log_ships_placement/ ; x
  b set
  :main::log_ships_placement
   
  x ; s/\(call_stack = [^\n]*\)/\1,main::draw/ ; x
  b draw
  :main::draw

  x ; s/\(call_stack = [^\n]*\)/\1,main::rng_seed/ ; x
  b rng_seed
  :main::rng_seed
 
  x ; s/\(call_stack = [^\n]*\)/\1,main::set_computer_ships/ ; x
  b set_computer_ships
  :main::set_computer_ships

  b player_move
}

### DIFFICULTY LEVEL CHOICE ###

:select_difficulty {
  s/^.*$/\c[[H\c[[J           === Sed Battleship by Red Void ===\n\nSelect a difficulty level:\n1. I can win\n2. Bring it on\n3. Hurt me plenty\n4. Hardcore\n5. \c[[31mNightmare!\c[[0m\n/ 
  p
  n
  /^[1-5]$/ {
    s/1/001/ ; s/2/010/ ; s/3/011/ ; s/4/100/ ; s/5/101/
    s/\([01]*\)$/\nluck = 00000000000000000000000000000\1/ 
    x ; s/\(call_stack = [^\n]*\)/\1,select_difficulty::set_luck/ ; x
    b set
    :select_difficulty::set_luck
    b return
  }
  s/^.*$//
  b select_difficulty
}

### POSITIONING LOGIC ###

:set_computer_ships {
  s/$/ships_to_place = ,1,1,1,1,2,2,2,3,3,4/
  x ; s/\(call_stack = [^\n]*\)/\1,set_computer_ships::create_ships/ ; x
  b set
  :set_computer_ships::create_ships

  :set_computer_ships::place_loop
  {
    x ; s/\(call_stack = [^\n]*\)/\1,set_computer_ships::draw/ ; x
    b draw
    :set_computer_ships::draw
    
    s/^.*$/ships_to_place/
    x ; s/\(call_stack = [^\n]*\)/\1,set_computer_ships::get_ships_to_place/ ; x
    b get
    :set_computer_ships::get_ships_to_place
  
    s/^\n$//
    /^$/ b set_computer_ships::end_placing

    s/\([^\n]*\),\([0-9]*\)$/\2\nships_to_place = \1/
    x ; s/\(call_stack = [^\n]*\)/\1,set_computer_ships::remove_ship/ ; x
    b set
    :set_computer_ships::remove_ship
  
    :set_computer_ships::got_ship
    
    # Generate random number
    x ; s/\(call_stack = [^\n]*\)/\1,set_computer_ships::gen_random/ ; x
    b rng
    :set_computer_ships::gen_random
     
    s/$/\nrng::current_state/
    x ; s/\(call_stack = [^\n]*\)/\1,set_computer_ships::get_random/ ; x
    b get
    :set_computer_ships::get_random
  
    s/0$/\nH/ ; s/1$/\nV/
    s/[01]*\([01]\{20\}\)\n\([HV]\)$/\2\ndiv::first_operand = \1\ndiv::second_operand = 00000000000001100100/
      
    x ; s/\(call_stack = [^\n]*\)/\1,set_computer_ships::prepare_coordinate_conversion_1/ ; x
    b set
    :set_computer_ships::prepare_coordinate_conversion_1
     
    x ; s/\(call_stack = [^\n]*\)/\1,set_computer_ships::prepare_coordinate_conversion_2/ ; x
    b set
    :set_computer_ships::prepare_coordinate_conversion_2
     
    x ; s/\(call_stack = [^\n]*\)/\1,set_computer_ships::convert_coordinates/ ; x
    b div
    :set_computer_ships::convert_coordinates
     
    s/$/\ndiv::mod_result/
    x ; s/\(call_stack = [^\n]*\)/\1,set_computer_ships::get_coordinates/ ; x
    b get
    :set_computer_ships::get_coordinates
  
    s/[01]*\([01]\{7\}\)$/\1/

    b set_computer_ships::valid_placement
    
    :set_computer_ships::invalid_placement
    {
      s/$/\nships_to_place/
      x ; s/\(call_stack = [^\n]*\)/\1,set_computer_ships::prepare_ship_to_return/ ; x
      b get
      :set_computer_ships::prepare_ship_to_return
       
      s/\([0-9]\)\n[^\n]*\n\([,0-9]*\)$/ships_to_place = \2,\1/
      x ; s/\(call_stack = [^\n]*\)/\1,set_computer_ships::return_ship/ ; x
      b set
      :set_computer_ships::return_ship

      b set_computer_ships::place_loop
    }

    :set_computer_ships::valid_placement
    {
      s/$/\nlast_action_log/ 
      x ; s/\(call_stack = [^\n]*\)/\1,set_computer_ships::get_current_log/ ; x
      b get
      :set_computer_ships::get_current_log
       
      s/\([^\n]*\)$/last_action_log = \1./ 
      x ; s/\(call_stack = [^\n]*\)/\1,set_computer_ships::log_valid_place/ ; x
      b set
      :set_computer_ships::log_valid_place

      # Convert the length, prepare variables to set
      s/\([1-4]\)\n\(.\)\n\([01]*\)$/place_ship::field = field::computer\nplace_ship::length = \1\nplace_ship::coordinates = \3\nplace_ship::orientation = \2/
      
      # Set all the variables
      x ; s/\(call_stack = [^\n]*\)/\1,set_computer_ships::set_orientation/ ; x
      b set
      :set_computer_ships::set_orientation
       
      x ; s/\(call_stack = [^\n]*\)/\1,set_computer_ships::set_coordinates/ ; x
      b set
      :set_computer_ships::set_coordinates
       
      x ; s/\(call_stack = [^\n]*\)/\1,set_computer_ships::set_length/ ; x
      b set
      :set_computer_ships::set_length
       
      x ; s/\(call_stack = [^\n]*\)/\1,set_computer_ships::set_field/ ; x
      b copy
      :set_computer_ships::set_field

      x ; s/\(call_stack = [^\n]*\)/\1,set_computer_ships::place_ship/ ; x
      b place_ship
      :set_computer_ships::place_ship

      s/$/\nplace_ship::result/
      x ; s/\(call_stack = [^\n]*\)/\1,set_computer_ships::get_placing_result/ ; x
      b get
      :set_computer_ships::get_placing_result

      /error/ {
        s/^.*$/\nplace_ship::length/
        x ; s/\(call_stack = [^\n]*\)/\1,set_computer_ships::handle_placing_error/ ; x
        b get
        :set_computer_ships::handle_placing_error
        s/$/\n/
        b set_computer_ships::invalid_placement
      }

      s/$/\nfield::computer = place_ship::field/
      x ; s/\(call_stack = [^\n]*\)/\1,set_computer_ships::update_field/ ; x
      b copy
      :set_computer_ships::update_field

      s/$/\nfield::computer_ships/
      x ; s/\(call_stack = [^\n]*\)/\1,set_computer_ships::get_computer_ships/ ; x
      b get
      :set_computer_ships::get_computer_ships

      s/^,\([01,]*\)\n\([^\n]*\)$/field::computer_ships = \2 \1/
      s/  / / # Hack for the first replacement
      x ; s/\(call_stack = [^\n]*\)/\1,set_computer_ships::update_computer_ships/ ; x
      b set
      :set_computer_ships::update_computer_ships
    }
    
    b set_computer_ships::place_loop
  }

  # Transform dots to waves
  :set_computer_ships::end_placing
  s/^.*$/field::computer/
  x ; s/\(call_stack = [^\n]*\)/\1,set_computer_ships::prepare_final_update/ ; x
  b get
  :set_computer_ships::prepare_final_update
  
  s/·/~/g
   
  s/^\n*\(.*\)$/\nfield::computer = \1/
  x ; s/\(call_stack = [^\n]*\)/\1,set_computer_ships::final_update/ ; x
  b set
  :set_computer_ships::final_update
   
  s/$/\nlast_action_log = Let the battle begin!/ 
  x ; s/\(call_stack = [^\n]*\)/\1,set_computer_ships::log_game_start/ ; x
  b set
  :set_computer_ships::log_game_start

  b return
}

:set_player_ships {
  s/$/ships_to_place = ,1,1,1,1,2,2,2,3,3,4/
  x ; s/\(call_stack = [^\n]*\)/\1,set_player_ships::create_ships/ ; x
  b set
  :set_player_ships::create_ships

  :set_player_ships::place_loop
  {
    x ; s/\(call_stack = [^\n]*\)/\1,set_player_ships::draw/ ; x
    b draw
    :set_player_ships::draw
    
    s/^.*$/ships_to_place/
    x ; s/\(call_stack = [^\n]*\)/\1,set_player_ships::get_ships_to_place/ ; x
    b get
    :set_player_ships::get_ships_to_place
  
    s/^\n$//
    /^$/ b set_player_ships::end_placing

    s/\([^\n]*\),\([0-9]*\)$/\2\nships_to_place = \1/
    x ; s/\(call_stack = [^\n]*\)/\1,set_player_ships::remove_ship/ ; x
    b set
    :set_player_ships::remove_ship
  
    :set_player_ships::got_ship
    
    s/^\(.*\)$/You're placing a ship of length \1. Set its upper left square and its orientation.\nE.g. 'B5V' (vertical) or 'G2H' (horizontal)\n/ ; p
    s/^.*length \([0-9]\).*$/\1/
    N
    
    # Input validation
    /\n[A-Ja-j][0-9][hvHV]$/ b set_player_ships::valid_placement
    
    :set_player_ships::invalid_placement
    {
      s/$/\nships_to_place/
      x ; s/\(call_stack = [^\n]*\)/\1,set_player_ships::prepare_ship_to_return/ ; x
      b get
      :set_player_ships::prepare_ship_to_return
       
      s/\([0-9]\)\n[^\n]*\n\([,0-9]*\)$/ships_to_place = \2,\1/
      x ; s/\(call_stack = [^\n]*\)/\1,set_player_ships::return_ship/ ; x
      b set
      :set_player_ships::return_ship

      s/$/\nlast_action_log = Cannot place a ship. Try again./ 
      x ; s/\(call_stack = [^\n]*\)/\1,set_player_ships::log_invalid_place/ ; x
      b set
      :set_player_ships::log_invalid_place
      
      b set_player_ships::place_loop
    }

    :set_player_ships::valid_placement
    {
      s/$/\nlast_action_log = Place yet another ship./ 
      x ; s/\(call_stack = [^\n]*\)/\1,set_player_ships::log_valid_place/ ; x
      b set
      :set_player_ships::log_valid_place

      s/\([1-4]\)\n\(..\)\(.\)$/\1\n\3\nconvert_coordinates::coordinates = \2/
      x ; s/\(call_stack = [^\n]*\)/\1,set_player_ships::prepare_coordinate_conversion/ ; x
      b set
      :set_player_ships::prepare_coordinate_conversion
      
      # Coordinates conversion
      x ; s/\(call_stack = [^\n]*\)/\1,set_player_ships::convert_coordinates/ ; x
      b convert_coordinates
      :set_player_ships::convert_coordinates

      s/$/\nconvert_coordinates::result/
      x ; s/\(call_stack = [^\n]*\)/\1,set_player_ships::set_start_coordinate/ ; x
      b get
      :set_player_ships::set_start_coordinate
    
      # Convert the length, prepare variables to set
      s/\([1-4]\)\n\(.\)\n\([01]*\)$/place_ship::field = field::player\nplace_ship::length = \1\nplace_ship::coordinates = \3\nplace_ship::orientation = \2/
      
      # Set all the variables
      x ; s/\(call_stack = [^\n]*\)/\1,set_player_ships::set_orientation/ ; x
      b set
      :set_player_ships::set_orientation
       
      x ; s/\(call_stack = [^\n]*\)/\1,set_player_ships::set_coordinates/ ; x
      b set
      :set_player_ships::set_coordinates
       
      x ; s/\(call_stack = [^\n]*\)/\1,set_player_ships::set_length/ ; x
      b set
      :set_player_ships::set_length
       
      x ; s/\(call_stack = [^\n]*\)/\1,set_player_ships::set_field/ ; x
      b copy
      :set_player_ships::set_field

      x ; s/\(call_stack = [^\n]*\)/\1,set_player_ships::place_ship/ ; x
      b place_ship
      :set_player_ships::place_ship

      s/$/\nplace_ship::result/
      x ; s/\(call_stack = [^\n]*\)/\1,set_player_ships::get_placing_result/ ; x
      b get
      :set_player_ships::get_placing_result

      /error/ {
        s/^.*$/\nplace_ship::length/
        x ; s/\(call_stack = [^\n]*\)/\1,set_player_ships::handle_placing_error/ ; x
        b get
        :set_player_ships::handle_placing_error
        s/$/\n/
        b set_player_ships::invalid_placement
      }

      s/$/\nfield::player = place_ship::field/
      x ; s/\(call_stack = [^\n]*\)/\1,set_player_ships::update_field/ ; x
      b copy
      :set_player_ships::update_field

      s/$/\nfield::player_ships/
      x ; s/\(call_stack = [^\n]*\)/\1,set_player_ships::get_player_ships/ ; x
      b get
      :set_player_ships::get_player_ships

      s/^,\([01,]*\)\n\([^\n]*\)$/field::player_ships = \2 \1/
      s/  / / # Hack for the first replacement
      x ; s/\(call_stack = [^\n]*\)/\1,set_player_ships::update_player_ships/ ; x
      b set
      :set_player_ships::update_player_ships
    }
    
    b set_player_ships::place_loop
  }

  # Transform waves to dots
  :set_player_ships::end_placing
  s/^.*$/field::player/
  x ; s/\(call_stack = [^\n]*\)/\1,set_player_ships::prepare_final_update/ ; x
  b get
  :set_player_ships::prepare_final_update
  
  s/~/·/g
   
  s/^\n*\(.*\)$/\nfield::player = \1/
  x ; s/\(call_stack = [^\n]*\)/\1,set_player_ships::final_update/ ; x
  b set
  :set_player_ships::final_update

  s/$/\nlast_action_log = Let the battle begin!/ 
  x ; s/\(call_stack = [^\n]*\)/\1,set_player_ships::log_game_start/ ; x
  b set
  :set_player_ships::log_game_start

  b return
}

:place_ship {
  # Init result
  s/^.*$/place_ship::result = /
  x ; s/\(call_stack = [^\n]*\)/\1,place_ship::init_result/ ; x
  b set
  :place_ship::init_result

  # Init border flag, coordinate list, counter
  s/^.*$/0\n\n0/

  s/$/\nplace_ship::length/
  x ; s/\(call_stack = [^\n]*\)/\1,place_ship::get_length/ ; x
  b get
  :place_ship::get_length

  s/$/\nplace_ship::orientation/
  x ; s/\(call_stack = [^\n]*\)/\1,place_ship::get_orientation/ ; x
  b get
  :place_ship::get_orientation
  
  s/$/\nplace_ship::coordinates/
  x ; s/\(call_stack = [^\n]*\)/\1,place_ship::get_coordinates/ ; x
  b get
  :place_ship::get_coordinates

  # Collecting coordinates
  :place_ship::collecting
    # check border flag, return error in case we are ready to cross it 
    /^1/ b place_ship::invalid_placement

    # if the current coordinate is not on the dot, return error
    s/$/\nget_symbol::string = place_ship::field/
    x ; s/\(call_stack = [^\n]*\)/\1,place_ship::set_field_string/ ; x
    b copy
    :place_ship::set_field_string
      
    s/\([01]*\)$/\1\nget_symbol::number = \1/
    x ; s/\(call_stack = [^\n]*\)/\1,place_ship::set_coordinate_to_get/ ; x
    b set
    :place_ship::set_coordinate_to_get
  
    x ; s/\(call_stack = [^\n]*\)/\1,place_ship::get_potential_cell/ ; x
    b get_symbol 
    :place_ship::get_potential_cell

    s/$/\nget_symbol::result/
    x ; s/\(call_stack = [^\n]*\)/\1,place_ship::put_potential_cell/ ; x
    b get
    :place_ship::put_potential_cell
    /[~H]$/ b place_ship::invalid_placement

    # Add the current coordinate to the list
    s/^\([01]\)\n\([01,]*\)\n\([0-4]\n[0-4]\n[HVhv]\)\n\([01]*\)\n[·~HDX]$/\1\n\2,\4\n\3\n\4/
    
    # Set border flag if necessary
    s/\([01]*\)$/\1\ndiv::first_operand = \1/
    x ; s/\(call_stack = [^\n]*\)/\1,place_ship::div_set_1/ ; x
    b set
    :place_ship::div_set_1

    s/$/\ndiv::second_operand = 0001010/
    x ; s/\(call_stack = [^\n]*\)/\1,place_ship::div_set_2/ ; x
    b set
    :place_ship::div_set_2

    x ; s/\(call_stack = [^\n]*\)/\1,place_ship::execute_div/ ; x
    b div
    :place_ship::execute_div
    
    # Horizontal border reach
    /[Hh]/ { 
      s/$/\ndiv::mod_result/
      x ; s/\(call_stack = [^\n]*\)/\1,place_ship::get_mod_result/ ; x
      b get
      :place_ship::get_mod_result

      /0001001$/ s/^0/1/
      s/\n[01]*$//
    }
    
    # Vertical border reach
    /[Vv]/ { 
      s/$/\ndiv::div_result/
      x ; s/\(call_stack = [^\n]*\)/\1,place_ship::get_div_result/ ; x
      b get
      :place_ship::get_div_result

      /0001001$/ s/^0/1/
      s/\n[01]*$//
    }

    # Change the coordinate
    # Set the first operand
    s/\([01]*\)$/\nadd::first_operand = \1/
    x ; s/\(call_stack = [^\n]*\)/\1,place_ship::prepare_coordinate_change_1/ ; x
    b set
    :place_ship::prepare_coordinate_change_1
    
    # Horizontal orientation
    /[Hh]/ s/$/\nadd::second_operand = 0000001/
    # Vertical orientation
    /[Vv]/ s/$/\nadd::second_operand = 0001010/

    x ; s/\(call_stack = [^\n]*\)/\1,place_ship::prepare_coordinate_change_2/ ; x
    b set
    :place_ship::prepare_coordinate_change_2

    x ; s/\(call_stack = [^\n]*\)/\1,place_ship::calculate_next_coordinate/ ; x
    b add
    :place_ship::calculate_next_coordinate

    s/$/add::result/
    x ; s/\(call_stack = [^\n]*\)/\1,place_ship::get_next_coordinate/ ; x
    b get
    :place_ship::get_next_coordinate

    # Quick counter increment: no need to use a common procedure for 4 cases only.
    # That's also why we didn't convert it to the binary form.
    s/^\([01]\)\n\([01,]*\)\n3/\1\n\2\n4/ ; s/^\([01]\)\n\([01,]*\)\n2/\1\n\2\n3/ ; s/^\([01]\)\n\([01,]*\)\n1/\1\n\2\n2/ ; s/^\([01]\)\n\([01,]*\)\n0/\1\n\2\n1/ 

    # end or continue the collecting process
    /^[01]\n[01,]*\n\([1-4]\)\n\1/ {
      s/^[01]\n\([01,]*\).*$/\1/
      b place_ship::place
    }
    
    b place_ship::collecting

    :place_ship::invalid_placement
    {
      s/^.*$/place_ship::result = error/
      x ; s/\(call_stack = [^\n]*\)/\1,place_ship::set_error/ ; x
      b set
      :place_ship::set_error
      b return
    }

  :place_ship::place
  
  s/^\([01,]*\)$/\1\nplace_ship::result = \1/
  x ; s/\(call_stack = [^\n]*\)/\1,place_ship::update_ship_placement/ ; x
  b set
  :place_ship::update_ship_placement
  
  # Make field changes
  :place_ship::loop
  /^,/ {
    # Mark ship cell
    s/$/\nset_symbol::symbol = H/
    x ; s/\(call_stack = [^\n]*\)/\1,place_ship::set_ship_symbol/ ; x
    b set
    :place_ship::set_ship_symbol
    
    s/\([01]*\)$/\1\nset_symbol::number = \1/
    x ; s/\(call_stack = [^\n]*\)/\1,place_ship::set_cell_number/ ; x
    b set
    :place_ship::set_cell_number

    s/$/\nset_symbol::string = place_ship::field/
    x ; s/\(call_stack = [^\n]*\)/\1,place_ship::set_field/ ; x
    b copy
    :place_ship::set_field
  
    x ; s/\(call_stack = [^\n]*\)/\1,place_ship::mark_ship/ ; x
    b set_symbol 
    :place_ship::mark_ship

    s/$/\nplace_ship::field = set_symbol::result/
    x ; s/\(call_stack = [^\n]*\)/\1,place_ship::update_field/ ; x
    b copy
    :place_ship::update_field

    # Mark diagonal cross
    s/\([01]*\)$/\1\nmark::coordinates = \1/
    x ; s/\(call_stack = [^\n]*\)/\1,place_ship::prepare_diagonal_mark_coordinates/ ; x
    b set
    :place_ship::prepare_diagonal_mark_coordinates

    s/$/\nmark::field = place_ship::field/
    x ; s/\(call_stack = [^\n]*\)/\1,place_ship::prepare_diagonal_mark_field/ ; x
    b copy
    :place_ship::prepare_diagonal_mark_field

    x ; s/\(call_stack = [^\n]*\)/\1,place_ship::mark_diagonal_cross/ ; x
    b mark_diagonal_cross
    :place_ship::mark_diagonal_cross
    
    s/$/\nplace_ship::field = mark::field/
    x ; s/\(call_stack = [^\n]*\)/\1,place_ship::set_diagonal_cross/ ; x
    b copy
    :place_ship::set_diagonal_cross

    s/,[01]*$// # Delete the handled coordinate
    b place_ship::loop
  }
  
  # Mark circle
  s/$/\nmark::ship = place_ship::result/
  x ; s/\(call_stack = [^\n]*\)/\1,place_ship::set_ship_to_circle/ ; x
  b copy
  :place_ship::set_ship_to_circle
   
  x ; s/\(call_stack = [^\n]*\)/\1,place_ship::mark_circle/ ; x
  b mark_circle  
  :place_ship::mark_circle
  
  s/$/\nplace_ship::field = mark::field/
  x ; s/\(call_stack = [^\n]*\)/\1,place_ship::set_circle/ ; x
  b copy
  :place_ship::set_circle

  b return
}

### GAME LOGIC

:player_move {
  x ; s/\(call_stack = [^\n]*\)/\1,player_move::draw/ ; x
  b draw
  :player_move::draw
  # Input coordinates
  n
  # Move analysis
  /^[A-Ja-j] *[0-9]$/ { b player_move::valid_move}
  s/$/\nlast_action_log = Invalid move, type a single letter and a single digit like A0 or H5./
  x ; s/\(call_stack = [^\n]*\)/\1,player_move::invalid_move/ ; x
  b set
  :player_move::invalid_move
  b player_move

  :player_move::valid_move
  # Set coordinates to convert
  s/^\([^\n]*\)$/convert_coordinates::coordinates = \1/
  x ; s/\(call_stack = [^\n]*\)/\1,player_move::set_coordinates/ ; x
  b set
  :player_move::set_coordinates
  
  # Coordinates conversion
  x ; s/\(call_stack = [^\n]*\)/\1,player_move::convert_coordinates/ ; x
  b convert_coordinates
  :player_move::convert_coordinates

  # Set number and string to get the suggest cell
  s/$/\nget_symbol::string = field::suggestions/
  x ; s/\(call_stack = [^\n]*\)/\1,player_move::set_suggestion_string/ ; x
  b copy
  :player_move::set_suggestion_string
    
  s/$/\nget_symbol::number = convert_coordinates::result/
  x ; s/\(call_stack = [^\n]*\)/\1,player_move::set_number/ ; x
  b copy
  :player_move::set_number
  
  # Get the suggestion cell
  x ; s/\(call_stack = [^\n]*\)/\1,player_move::get_suggestion_cell/ ; x
  b get_symbol 
  :player_move::get_suggestion_cell

  # Put the suggestion cell into pattern space to analyze
  s/^.*$/get_symbol::result/
  x ; s/\(call_stack = [^\n]*\)/\1,player_move::put_suggestion_cell/ ; x
  b get
  :player_move::put_suggestion_cell
  
  # Try again if the cell has been already checked
  /[~DX]/ {
    s/$/\nlast_action_log = This cell has already been checked, try another one./
    x ; s/\(call_stack = [^\n]*\)/\1,player_move::already_checked/ ; x
    b set
    :player_move::already_checked
    b player_move
  }

  # Set string to get the enemy cell (the number is the same)
  s/$/\nget_symbol::string = field::computer/
  x ; s/\(call_stack = [^\n]*\)/\1,player_move::set_enemy_string/ ; x
  b copy
  :player_move::set_enemy_string

  # Get the enemy cell
  x ; s/\(call_stack = [^\n]*\)/\1,player_move::get_enemy_cell/ ; x
  b get_symbol 
  :player_move::get_enemy_cell

  # Put the enemy cell into pattern space to analyze
  s/^.*$/get_symbol::result/
  x ; s/\(call_stack = [^\n]*\)/\1,player_move::put_enemy_cell/ ; x
  b get
  :player_move::put_enemy_cell

  # In case we hit a ship it should become damaged
  s/H/D/

  # Prepare suggestions field change
  s/\([^\n]*\)$/\1\nset_symbol::symbol = \1/
  x ; s/\(call_stack = [^\n]*\)/\1,player_move::set_missed_symbol/ ; x
  b set
  :player_move::set_missed_symbol
  
  s/$/\nset_symbol::number = convert_coordinates::result/
  x ; s/\(call_stack = [^\n]*\)/\1,player_move::set_missed_number/ ; x
  b copy
  :player_move::set_missed_number

  s/$/\nset_symbol::string = field::suggestions/
  x ; s/\(call_stack = [^\n]*\)/\1,player_move::set_missed_string/ ; x
  b copy
  :player_move::set_missed_string

  # Perform suggestions field change
  x ; s/\(call_stack = [^\n]*\)/\1,player_move::change_missed_string/ ; x
  b set_symbol 
  :player_move::change_missed_string

  s/$/\nfield::suggestions = set_symbol::result/
  x ; s/\(call_stack = [^\n]*\)/\1,player_move::perform_missed/ ; x
  b copy
  :player_move::perform_missed

  # Miss handling
  /~$/ {
    s/$/\neaster = 00/
    x ; s/\(call_stack = [^\n]*\)/\1,player_move::easter_disable/ ; x
    b set
    :player_move::easter_disable

    s/$/\nlast_action_log = You've missed! Now it's my turn./
    x ; s/\(call_stack = [^\n]*\)/\1,player_move::log_miss/ ; x
    b set
    :player_move::log_miss
    b player_move::end_move
  }
  
  # Hit handling
  /D$/ {
    s/$/\nlast_action_log = Ouch! My ship is damaged!/
    x ; s/\(call_stack = [^\n]*\)/\1,player_move::log_hit/ ; x
    b set
    :player_move::log_hit
     
    s/\([^\n]*\)$/\1\nset_symbol::symbol = D/
    x ; s/\(call_stack = [^\n]*\)/\1,player_move::set_hit_symbol/ ; x
    b set
    :player_move::set_hit_symbol
  
    s/$/\nset_symbol::string = field::computer/
    x ; s/\(call_stack = [^\n]*\)/\1,player_move::set_hit_string/ ; x
    b copy
    :player_move::set_hit_string

    # Perform suggestions field change
    x ; s/\(call_stack = [^\n]*\)/\1,player_move::change_hit_string/ ; x
    b set_symbol 
    :player_move::change_hit_string

    s/$/\nfield::computer = set_symbol::result/
    x ; s/\(call_stack = [^\n]*\)/\1,player_move::perform_hit/ ; x
    b copy
    :player_move::perform_hit

    # make analysis
    s/$/\nanalyze_ship_state::coordinate = convert_coordinates::result/
    x ; s/\(call_stack = [^\n]*\)/\1,player_move::prepare_analysis_coordinate/ ; x
    b copy
    :player_move::prepare_analysis_coordinate
    
    s/$/\nanalyze_ship_state::ships = field::computer_ships/
    x ; s/\(call_stack = [^\n]*\)/\1,player_move::prepare_analysis_ships/ ; x
    b copy
    :player_move::prepare_analysis_ships
       
    s/$/\nanalyze_ship_state::field = field::computer/
    x ; s/\(call_stack = [^\n]*\)/\1,player_move::prepare_analysis_field/ ; x
    b copy
    :player_move::prepare_analysis_field

    x ; s/\(call_stack = [^\n]*\)/\1,player_move::analysis/ ; x
    b analyze_ship_state
    :player_move::analysis

    s/$/\nanalyze_ship_state::result/
    x ; s/\(call_stack = [^\n]*\)/\1,player_move::get_analysis_result/ ; x
    b get
    :player_move::get_analysis_result
  
    # Prepare marking variables: field and cell number
    s/$/\nmark::coordinates = convert_coordinates::result/
    x ; s/\(call_stack = [^\n]*\)/\1,player_move::prepare_mark_coordinates/ ; x
    b copy
    :player_move::prepare_mark_coordinates

    s/$/\nmark::field = field::suggestions/
    x ; s/\(call_stack = [^\n]*\)/\1,player_move::prepare_mark_field/ ; x
    b copy
    :player_move::prepare_mark_field

    # Mark 
    x ; s/\(call_stack = [^\n]*\)/\1,player_move::mark_diagonal_cross/ ; x
    b mark_diagonal_cross
    :player_move::mark_diagonal_cross
    
    s/$/\nfield::suggestions = mark::field/
    x ; s/\(call_stack = [^\n]*\)/\1,player_move::set_diagonal_cross/ ; x
    b copy
    :player_move::set_diagonal_cross
  
    /sunk$/ {
      s/\n*sunk$//
  
      # Update suggestions field
      s/$/\nmark::field = field::suggestions/
      x ; s/\(call_stack = [^\n]*\)/\1,player_move::update_before_sink/ ; x
      b copy
      :player_move::update_before_sink
    
      x ; s/\(call_stack = [^\n]*\)/\1,player_move::sink_ship/ ; x
      b sink_computer_ship
      :player_move::sink_ship
      
      # Get the ship cells
      s/$/\nmark::coordinates/
      x ; s/\(call_stack = [^\n]*\)/\1,player_move::get_hit_cell/ ; x
      b get
      :player_move::get_hit_cell
      
      s/$/\nfield::computer_ships/
      x ; s/\(call_stack = [^\n]*\)/\1,player_move::get_ship_list/ ; x
      b get
      :player_move::get_ship_list
    
      s/$/\nmark::field = field::suggestions/
      x ; s/\(call_stack = [^\n]*\)/\1,player_move::prepare_mark_field_2/ ; x
      b copy
      :player_move::prepare_mark_field_2
      
      s/\([^\n]*\)$/ \1/
      s/\([01]*\)\n[^\n]* \([01,]*\)\1\([01,]*\)[^\n]*$/,\2\1\3/
      s/\([01,]*\)$/mark::ship = \1/
      x ; s/\(call_stack = [^\n]*\)/\1,player_move::set_ship_cells/ ; x
      b set
      :player_move::set_ship_cells

      x ; s/\(call_stack = [^\n]*\)/\1,player_move::mark_circle/ ; x
      b mark_circle  
      :player_move::mark_circle
    
      # Change suggestions field
      s/$/\nfield::suggestions = mark::field/
      x ; s/\(call_stack = [^\n]*\)/\1,player_move::set_suggestions_field/ ; x
      b copy
      :player_move::set_suggestions_field
     
      s/$/\nlast_action_log = OK, you've managed to sink my ship. Happy?/
      x ; s/\(call_stack = [^\n]*\)/\1,player_move::log_sink/ ; x
      b set
      :player_move::log_sink
    }
    

    x ; s/\(call_stack = [^\n]*\)/\1,player_move::check_win/ ; x
    b check_win
    :player_move::check_win

    # Make yet another move
    b player_move
  }
  
  :player_move::end_move
  b computer_move
}

:analyze_ship_state
{
  # Init result
  s/$/\nanalyze_ship_state::result = /
  x ; s/\(call_stack = [^\n]*\)/\1,analyze_ship_state::init/ ; x
  b set
  :analyze_ship_state::init
  
  s/$/\nanalyze_ship_state::coordinate/
  x ; s/\(call_stack = [^\n]*\)/\1,analyze_ship_state::get_ship_cell/ ; x
  b get
  :analyze_ship_state::get_ship_cell

  s/$/\nanalyze_ship_state::ships/
  x ; s/\(call_stack = [^\n]*\)/\1,analyze_ship_state::get_all_ships/ ; x
  b get
  :analyze_ship_state::get_all_ships

  s/$/\nget_symbol::string = analyze_ship_state::field/
  x ; s/\(call_stack = [^\n]*\)/\1,analyze_ship_state::set_enemy_string/ ; x
  b copy
  :analyze_ship_state::set_enemy_string

  # Leave only the ship of this particular cell
  s/\([^\n]*\)$/ \1/
  s/\([01]*\)\n[^\n]* \([01,]*\)\1\([01,]*\)[^\n]*$/\2\1\3/
  
  :analyze_ship_state::cell_loop
  /[01]$/ {
    # Set cell number
    s/\([01]*\)$/\nget_symbol::number = \1/
    x ; s/\(call_stack = [^\n]*\)/\1,analyze_ship_state::set_enemy_cell/ ; x
    b set
    :analyze_ship_state::set_enemy_cell

    x ; s/\(call_stack = [^\n]*\)/\1,analyze_ship_state::calculate_enemy_cell/ ; x
    b get_symbol 
    :analyze_ship_state::calculate_enemy_cell

    s/$/\nget_symbol::result/
    x ; s/\(call_stack = [^\n]*\)/\1,analyze_ship_state::get_enemy_cell/ ; x
    b get
    :analyze_ship_state::get_enemy_cell
    
    # if we have a healthy cell, then the ship is just damaged
    /H$/ b analyze_ship_state::not_sunk

    # Delete analyzed cell
    s/[01]*\n[^\n]$//
    s/,$//
    b analyze_ship_state::cell_loop
  }

  s/D*\n*$/analyze_ship_state::result = sunk/
  x ; s/\(call_stack = [^\n]*\)/\1,analyze_ship_state::sunk/ ; x
  b set
  :analyze_ship_state::sunk

  :analyze_ship_state::not_sunk
  b return
}

:mark_circle
{
  # Get the computer ship cells
  s/$/\nmark::ship/
  x ; s/\(call_stack = [^\n]*\)/\1,mark_circle::get_ship_cells/ ; x
  b get
  :mark_circle::get_ship_cells

  :mark_circle::loop
  /[01]$/ {
    s/\([01]*\)$/\1\nmark_common_cross::cell = \1/
    x ; s/\(call_stack = [^\n]*\)/\1,mark_circle::set_ship_cell/ ; x
    b set
    :mark_circle::set_ship_cell

    x ; s/\(call_stack = [^\n]*\)/\1,mark_circle::mark_common_cross/ ; x
    b mark_common_cross
    :mark_circle::mark_common_cross
    s/,[01]*$//
    b mark_circle::loop
  }
  b return
}

:mark_common_cross
{
  # Set water symbol
  s/\([^\n]*\)$/\1\nset_symbol::symbol = ~/
  x ; s/\(call_stack = [^\n]*\)/\1,mark_common_cross::set_water_symbol/ ; x
  b set
  :mark_common_cross::set_water_symbol

  # We need to ensure that we are not moving from the field.
  # In order to do it we'll make a division and get separated coordinates
  s/$/\ndiv::first_operand = mark_common_cross::cell/
  x ; s/\(call_stack = [^\n]*\)/\1,mark_common_cross::div_set_1/ ; x
  b copy
  :mark_common_cross::div_set_1

  s/$/\ndiv::second_operand = 0001010/
  x ; s/\(call_stack = [^\n]*\)/\1,mark_common_cross::div_set_2/ ; x
  b set
  :mark_common_cross::div_set_2

  # Perform division and get the final result
  x ; s/\(call_stack = [^\n]*\)/\1,mark_common_cross::execute_div/ ; x
  b div
  :mark_common_cross::execute_div

  # Get division results
  s/$/\ndiv::div_result/
  x ; s/\(call_stack = [^\n]*\)/\1,mark_common_cross::get_y_coordinate/ ; x
  b get
  :mark_common_cross::get_y_coordinate

  s/$/\ndiv::mod_result/
  x ; s/\(call_stack = [^\n]*\)/\1,mark_common_cross::get_x_coordinate/ ; x
  b get
  :mark_common_cross::get_x_coordinate

  # Get the computer ship cells
  s/$/\nmark::ship/
  x ; s/\(call_stack = [^\n]*\)/\1,mark_common_cross::get_ship_cells/ ; x
  b get
  :mark_common_cross::get_ship_cells

  # Save addends to move to the adjacent cells
  s/$/\n,0001010,1110110,0000001,1111111/
  :mark_common_cross::loop
  /[01]$/ {
    # North: do not subtract 10 in case y_coordinate is 0
    /0000000\n[01]*\n[01,]*\n[01,]*,1110110$/ b mark_common_cross::cross_cell_handled
    # South: do not add 10 in case y_coordinate is 9
    /0001001\n[01]*\n[01,]*\n[01,]*,0001010$/ b mark_common_cross::cross_cell_handled
    # West: do not subtract 1 in case x_coordinate is 0
    /0000000\n[01,]*\n[01,]*,1111111$/ b mark_common_cross::cross_cell_handled
    # East: do not add 1 in case x_coordinate is 9
    /0001001\n[01,]*\n[01,]*,0000001$/ b mark_common_cross::cross_cell_handled

    # Set the first addend: the cell we hit
    s/$/\nadd::first_operand = mark_common_cross::cell/
    x ; s/\(call_stack = [^\n]*\)/\1,mark_common_cross::set_add_1/ ; x
    b copy
    :mark_common_cross::set_add_1

    # Set the second addend: 1, 10, -1 or -10
    s/\([01]*\)$/\1\nadd::second_operand = \1/
    x ; s/\(call_stack = [^\n]*\)/\1,mark_common_cross::set_add_2/ ; x
    b set
    :mark_common_cross::set_add_2

    # Perform the addition
    x ; s/\(call_stack = [^\n]*\)/\1,mark_common_cross::calculate_cross_cell/ ; x
    b add
    :mark_common_cross::calculate_cross_cell

    # Additional check if the resulting cell is really empty (it may contain the part of the sunk ship)
    s/$/\nadd::result/
    x ; s/\(call_stack = [^\n]*\)/\1,mark_common_cross::set_cell_to_check/ ; x
    b get
    :mark_common_cross::set_cell_to_check

    s/\([01,]*\)\n\([01,]*\)\n\([01]*\)$/\1\n\2\n\3 \1/
    /\n\([01]*\) [01,]*\1[01,]*$/ {s/\n[01, ]*$// ; b mark_common_cross::cross_cell_handled ; }

    # Clear the check artifact
    s/\n[01, ]*$//
  
    # Set the cell number
    s/\([^\n]*\)$/\1\nset_symbol::number = add::result/
    x ; s/\(call_stack = [^\n]*\)/\1,mark_common_cross::set_mark_cell/ ; x
    b copy
    :mark_common_cross::set_mark_cell

    # Prepare suggestions field to change
    s/$/\nset_symbol::string = mark::field/
    x ; s/\(call_stack = [^\n]*\)/\1,mark_common_cross::set_suggestions_string/ ; x
    b copy
    :mark_common_cross::set_suggestions_string

    # Perform suggestions field change
    x ; s/\(call_stack = [^\n]*\)/\1,mark_common_cross::perform_field_change/ ; x
    b set_symbol 
    :mark_common_cross::perform_field_change

    # Set new suggestions field
    s/$/\nmark::field = set_symbol::result/
    x ; s/\(call_stack = [^\n]*\)/\1,mark_common_cross::change_suggestions_field/ ; x
    b copy
    :mark_common_cross::change_suggestions_field

    :mark_common_cross::cross_cell_handled
    # Clean the handled cell
    s/,[01]*$//
    b mark_common_cross::loop
  }
  s/\n[01]*\n[01]*\n[01,]*\n*$//
  b return
}

:mark_diagonal_cross
{
  # Set water symbol
  s/\([^\n]*\)$/\1\nset_symbol::symbol = ~/
  x ; s/\(call_stack = [^\n]*\)/\1,mark_diagonal_cross::set_water_symbol/ ; x
  b set
  :mark_diagonal_cross::set_water_symbol

  # We need to ensure that we are not moving from the field.
  # In order to do it we'll make a division and get separated coordinates
  s/$/\ndiv::first_operand = mark::coordinates/
  x ; s/\(call_stack = [^\n]*\)/\1,mark_diagonal_cross::div_set_1/ ; x
  b copy
  :mark_diagonal_cross::div_set_1

  s/$/\ndiv::second_operand = 0001010/
  x ; s/\(call_stack = [^\n]*\)/\1,mark_diagonal_cross::div_set_2/ ; x
  b set
  :mark_diagonal_cross::div_set_2

  # Perform division and get the final result
  x ; s/\(call_stack = [^\n]*\)/\1,mark_diagonal_cross::execute_div/ ; x
  b div
  :mark_diagonal_cross::execute_div

  # Get division results
  s/$/\ndiv::div_result/
  x ; s/\(call_stack = [^\n]*\)/\1,mark_diagonal_cross::get_y_coordinate/ ; x
  b get
  :mark_diagonal_cross::get_y_coordinate

  s/$/\ndiv::mod_result/
  x ; s/\(call_stack = [^\n]*\)/\1,mark_diagonal_cross::get_x_coordinate/ ; x
  b get
  :mark_diagonal_cross::get_x_coordinate
  
  # Save addends to move to the diagonal cells
  s/$/\n,1110101,1110111,0001001,0001011/
  :mark_diagonal_cross::loop
  /[01]$/ {
    # North: do not subtract in case y_coordinate is 0
    /0000000\n[01]*\n[01,]*,1[01]*$/ b mark_diagonal_cross::cross_cell_handled
    # South: do not add in case y_coordinate is 9
    /0001001\n[01]*\n[01,]*,0[01]*$/ b mark_diagonal_cross::cross_cell_handled
    # West: do not add 9 or subtract 11 in case x_coordinate is 0
    /0000000\n[01,]*,[01]*01$/ b mark_diagonal_cross::cross_cell_handled
    # East: do not add 11 or subtract 9 in case x_coordinate is 9
    /0001001\n[01,]*,[01]*11$/ b mark_diagonal_cross::cross_cell_handled

    # Set the first addend: the cell we hit
    s/$/\nadd::first_operand = mark::coordinates/
    x ; s/\(call_stack = [^\n]*\)/\1,mark_diagonal_cross::set_add_1/ ; x
    b copy
    :mark_diagonal_cross::set_add_1

    # Set the second addend: 9, 11, -9 or -11
    s/\([01]*\)$/\1\nadd::second_operand = \1/
    x ; s/\(call_stack = [^\n]*\)/\1,mark_diagonal_cross::set_add_2/ ; x
    b set
    :mark_diagonal_cross::set_add_2

    # Perform the addition
    x ; s/\(call_stack = [^\n]*\)/\1,mark_diagonal_cross::calculate_cross_cell/ ; x
    b add
    :mark_diagonal_cross::calculate_cross_cell

    # Set the cell number
    s/\([^\n]*\)$/\1\nset_symbol::number = add::result/
    x ; s/\(call_stack = [^\n]*\)/\1,mark_diagonal_cross::set_mark_cell/ ; x
    b copy
    :mark_diagonal_cross::set_mark_cell

    # Prepare suggestions field to change
    s/$/\nset_symbol::string = mark::field/
    x ; s/\(call_stack = [^\n]*\)/\1,mark_diagonal_cross::set_suggestions_string/ ; x
    b copy
    :mark_diagonal_cross::set_suggestions_string

    # Perform suggestions field change
    x ; s/\(call_stack = [^\n]*\)/\1,mark_diagonal_cross::perform_field_change/ ; x
    b set_symbol 
    :mark_diagonal_cross::perform_field_change

    # Set new suggestions field
    s/$/\nmark::field = set_symbol::result/
    x ; s/\(call_stack = [^\n]*\)/\1,mark_diagonal_cross::change_suggestions_field/ ; x
    b copy
    :mark_diagonal_cross::change_suggestions_field

    :mark_diagonal_cross::cross_cell_handled
    # Clean the handled cell
    s/,[01]*$//
    b mark_diagonal_cross::loop
  }

  # Clean artifacts
  s/\n[01]*\n[01]*\n$//
  b return
}


:sink_player_ship
{
  # Get hit cell
  s/$/\nreverse_convert_coordinates::result_number/
  x ; s/\(call_stack = [^\n]*\)/\1,sink_player_ship::get_ship_cell/ ; x
  b get
  :sink_player_ship::get_ship_cell

  # Get player ships
  s/$/\nfield::player_ships/
  x ; s/\(call_stack = [^\n]*\)/\1,sink_player_ship::get_all_ships/ ; x
  b get
  :sink_player_ship::get_all_ships

  # Leave the only ship we need
  s/\([^\n]*\)$/ \1/
  s/\([01]*\)\n[^\n]* \([01,]*\)\1\([01,]*\)[^\n]*$/\2\1\3/

  # Set sunk ship symbol
  s/\([^\n]*\)$/\1\nset_symbol::symbol = X/
  x ; s/\(call_stack = [^\n]*\)/\1,sink_player_ship::set_sink_symbol/ ; x
  b set
  :sink_player_ship::set_sink_symbol

  :sink_player_ship::sink_loop
  /[01]$/ {
    # Setting number of cell to sink
    s/\([01]*\)$/\nset_symbol::number = \1/
    x ; s/\(call_stack = [^\n]*\)/\1,sink_player_ship::set_cell_number/ ; x
    b set
    :sink_player_ship::set_cell_number
  
    # Prepare player field to change
    s/$/\nset_symbol::string = field::player/
    x ; s/\(call_stack = [^\n]*\)/\1,sink_player_ship::set_enemy_string/ ; x
    b copy
    :sink_player_ship::set_enemy_string

    # Perform player field change
    x ; s/\(call_stack = [^\n]*\)/\1,sink_player_ship::change_enemy_field/ ; x
    b set_symbol 
    :sink_player_ship::change_enemy_field

    s/$/\nfield::player = set_symbol::result/
    x ; s/\(call_stack = [^\n]*\)/\1,sink_player_ship::save_enemy_field/ ; x
    b copy
    :sink_player_ship::save_enemy_field
    
    s/[01]*\n[^\n]$//
    s/,$//
    b sink_player_ship::sink_loop
  }

  b return
}


:sink_computer_ship
{
  # Get hit cell
  s/$/\nconvert_coordinates::result/
  x ; s/\(call_stack = [^\n]*\)/\1,sink_computer_ship::get_ship_cell/ ; x
  b get
  :sink_computer_ship::get_ship_cell

  # Get computer ships
  s/$/\nfield::computer_ships/
  x ; s/\(call_stack = [^\n]*\)/\1,sink_computer_ship::get_all_ships/ ; x
  b get
  :sink_computer_ship::get_all_ships

  # Leave the only ship we need
  s/\([^\n]*\)$/ \1/
  s/\([01]*\)\n[^\n]* \([01,]*\)\1\([01,]*\)[^\n]*$/\2\1\3/

  # Set sunk ship symbol
  s/\([^\n]*\)$/\1\nset_symbol::symbol = X/
  x ; s/\(call_stack = [^\n]*\)/\1,sink_computer_ship::set_sink_symbol/ ; x
  b set
  :sink_computer_ship::set_sink_symbol

  :sink_computer_ship::sink_loop
  /[01]$/ {
    # Setting number of cell to sink
    s/\([01]*\)$/\nset_symbol::number = \1/
    x ; s/\(call_stack = [^\n]*\)/\1,sink_computer_ship::set_cell_number/ ; x
    b set
    :sink_computer_ship::set_cell_number
  
    # Prepare enemy field to change
    s/$/\nset_symbol::string = field::computer/
    x ; s/\(call_stack = [^\n]*\)/\1,sink_computer_ship::set_enemy_string/ ; x
    b copy
    :sink_computer_ship::set_enemy_string

    # Perform enemy field change
    x ; s/\(call_stack = [^\n]*\)/\1,sink_computer_ship::change_enemy_field/ ; x
    b set_symbol 
    :sink_computer_ship::change_enemy_field

    s/$/\nfield::computer = set_symbol::result/
    x ; s/\(call_stack = [^\n]*\)/\1,sink_computer_ship::save_enemy_field/ ; x
    b copy
    :sink_computer_ship::save_enemy_field
    
    # Prepare suggestions field to change
    s/$/\nset_symbol::string = field::suggestions/
    x ; s/\(call_stack = [^\n]*\)/\1,sink_computer_ship::set_suggestions_string/ ; x
    b copy
    :sink_computer_ship::set_suggestions_string

    # Perform suggestions field change
    x ; s/\(call_stack = [^\n]*\)/\1,sink_computer_ship::change_suggestions_field/ ; x
    b set_symbol 
    :sink_computer_ship::change_suggestions_field

    s/$/\nfield::suggestions = set_symbol::result/
    x ; s/\(call_stack = [^\n]*\)/\1,sink_computer_ship::save_suggestions_field/ ; x
    b copy
    :sink_computer_ship::save_suggestions_field
    s/[01]*\n[^\n]$//
    s/,$//
    b sink_computer_ship::sink_loop
  }

  b return
}

# The algorithm is long but rather simple:
# First of all, we get healthy cells number and total cells number in the player field.
# Then we generate random number from 0 to (2*total_cells + healthy_cells*luck - 1).
# if random_number < 2*healthy_cells + healthy_cells*luck {
#   # Hit a ship
#   return random_number / (2 + luck) 
# } else {
#   # Miss
#    return (random_number - (2*healthy_cells + healthy_cells*luck)) / 2 
# }
:generate_computer_move {
  # Generate random number
  x ; s/\(call_stack = [^\n]*\)/\1,generate_computer_move::random/ ; x
  b rng
  :generate_computer_move::random
  
  # Calculate limit: 2*(total_unchecked_cells) + healthy_ship_cells*luck
  s/$/\nfield::player/
  x ; s/\(call_stack = [^\n]*\)/\1,generate_computer_move::get_player_field/ ; x
  b get
  :generate_computer_move::get_player_field

  # Init counters: total cells and healthy ship cells
  # 32 bits are enough to handle really large luck (in case you want to make a bot stronger)
  s/\n\([^\n]*\)$/00000000000000000000000000000000\n00000000000000000000000000000000\n\1/
  :generate_computer_move::calculate_cells_loop
  /H$/ {
    # Inlined increment loop
    :generate_computer_move::inc_healthy_count_loop
    /\n0*\n[·~HDX]*$/ {s/\(0*\)0\n\([^\n]*\)$/\11\n\2/ ; b generate_computer_move::inc_healthy_reverseloop; }
    :generate_computer_move::inc_healthy_loop ; s/1\(_*\)\n\([^\n]*\)$/_\1\n\2/ ; /1_*\n[^\n]*$/ b generate_computer_move::inc_healthy_loop
    s/0\(_*\)\n\([^\n]*\)$/1\1\n\2/
    :generate_computer_move::inc_healthy_reverseloop ; s/_\(_*\)\n\([^\n]*\)$/0\1\n\2/ ; /_\n[^\n]*$/ b generate_computer_move::inc_healthy_reverseloop ;
  }
  /[·H]$/ {
    # Inlined increment loop
    :generate_computer_move::inc_total_count_loop
    /^0*\n[01]*\n[^\n]*$/ {s/\(0*\)0\n\([01]*\)\n\([^\n]*\).$/\11\n\2\n\3/ ; b generate_computer_move::inc_total_reverseloop; }
    :generate_computer_move::inc_total_loop ; s/1\(_*\)\n\([01]*\)\n\([^\n]*\)$/_\1\n\2\n\3/ ; /1_*\n[01]*\n[^\n]*$/ b generate_computer_move::inc_total_loop
    s/0\(_*\)\n\([01]*\)\n\([^\n]*\)$/1\1\n\2\n\3/
    :generate_computer_move::inc_total_reverseloop ; s/_\(_*\)\n\([01]*\)\n\([^\n]*\)$/0\1\n\2\n\3/ ; /_\n[01]*\n[^\n]*$/ b generate_computer_move::inc_total_reverseloop ;
  }
  # Delete the last element
  s/.$//
  /[^\n]$/ b generate_computer_move::calculate_cells_loop
  s/\n$//
  
  # Prepare the first addend: 2 * healthy_cells
  s/\([01]\)\([01]*\)$/\1\2\ngenerate_computer_move::2_healthy_cells = \20/
  x ; s/\(call_stack = [^\n]*\)/\1,generate_computer_move::save_2_healthy_cells/ ; x
  b set
  :generate_computer_move::save_2_healthy_cells
  
  # Prepare the first addend: 2 * total_cells
  s/[01]\([01]*\)\n\([01]*\)$/\2\ngenerate_computer_move::total_cells_factor = \10/
  x ; s/\(call_stack = [^\n]*\)/\1,generate_computer_move::save_total_cells_factor/ ; x
  b set
  :generate_computer_move::save_total_cells_factor
  
  # Prepare the second addend: healthy_cells * luck
  s/\([01]*\)$/mul::first_operand = \1/
  x ; s/\(call_stack = [^\n]*\)/\1,generate_computer_move::prepare_healthy_cells_factor_1/ ; x
  b set
  :generate_computer_move::prepare_healthy_cells_factor_1

  s/$/\nmul::second_operand = luck/
  x ; s/\(call_stack = [^\n]*\)/\1,generate_computer_move::prepare_healthy_cells_factor_2/ ; x
  b copy
  :generate_computer_move::prepare_healthy_cells_factor_2

  # Perform multiplication
  x ; s/\(call_stack = [^\n]*\)/\1,generate_computer_move::perform_mul/ ; x
  b mul
  :generate_computer_move::perform_mul

  s/$/\ngenerate_computer_move::healthy_cells_factor = mul::result/
  x ; s/\(call_stack = [^\n]*\)/\1,generate_computer_move::save_healthy_cells_factor/ ; x
  b copy
  :generate_computer_move::save_healthy_cells_factor
  
  # Prepare addition
  s/$/\nadd::first_operand = mul::result/
  x ; s/\(call_stack = [^\n]*\)/\1,generate_computer_move::prepare_add_1/ ; x
  b copy
  :generate_computer_move::prepare_add_1
  
  s/$/\nadd::second_operand = generate_computer_move::total_cells_factor/
  x ; s/\(call_stack = [^\n]*\)/\1,generate_computer_move::prepare_add_2/ ; x
  b copy
  :generate_computer_move::prepare_add_2

  # Perform addition
  x ; s/\(call_stack = [^\n]*\)/\1,generate_computer_move::perform_add/ ; x
  b add
  :generate_computer_move::perform_add

  # Div generated random number by limit
  s/$/\ndiv::first_operand = rng::current_state/
  x ; s/\(call_stack = [^\n]*\)/\1,generate_computer_move::prepare_random_limitation_1/ ; x
  b copy
  :generate_computer_move::prepare_random_limitation_1

  s/$/\ndiv::second_operand = add::result/
  x ; s/\(call_stack = [^\n]*\)/\1,generate_computer_move::prepare_random_limitation_2/ ; x
  b copy
  :generate_computer_move::prepare_random_limitation_2

  x ; s/\(call_stack = [^\n]*\)/\1,generate_computer_move::perform_random_limitation/ ; x
  b div
  :generate_computer_move::perform_random_limitation

  # Prepare set partition limit
  s/$/\nadd::first_operand = generate_computer_move::healthy_cells_factor/
  x ; s/\(call_stack = [^\n]*\)/\1,generate_computer_move::prepare_set_partition_limit_1/ ; x
  b copy
  :generate_computer_move::prepare_set_partition_limit_1
  
  s/$/\nadd::second_operand = generate_computer_move::2_healthy_cells/
  x ; s/\(call_stack = [^\n]*\)/\1,generate_computer_move::prepare_set_partition_limit_2/ ; x
  b copy
  :generate_computer_move::prepare_set_partition_limit_2

  # Perform addition
  x ; s/\(call_stack = [^\n]*\)/\1,generate_computer_move::calculate_set_partition_limit/ ; x
  b add
  :generate_computer_move::calculate_set_partition_limit

  # Compare if the random number is greater than set partition number
  s/$/\ndiv::mod_result/
  x ; s/\(call_stack = [^\n]*\)/\1,generate_computer_move::get_limited_random/ ; x
  b get
  :generate_computer_move::get_limited_random

  s/$/\nadd::result/
  x ; s/\(call_stack = [^\n]*\)/\1,generate_computer_move::get_set_partition_limit/ ; x
  b get
  :generate_computer_move::get_set_partition_limit

  # Compare  procedure
  /\([01]*\)\n\1$/ b generate_computer_move::miss_result
  s/\([01]*\)\n\([01]*\)$/ \1\n \2/
  :generate_computer_move::compare_loop
    s/\([01]*\) \([01]\)\([01]*\)\n\([01]*\) \([01]\)\([01]*\)$/\1\2 \3\n\4\5 \6/
    /0 [01]*\n[01]*1 [01]*$/ b generate_computer_move::hit_result
    /1 [01]*\n[01]*0 [01]*$/ b generate_computer_move::miss_result
    b generate_computer_move::compare_loop

  :generate_computer_move::hit_result {
    s/\([01]*\) \([01]*\)\n[01 ]*$/\1\2/
    
    # We need to divide limited random by 2+luck. First of all, let's build the divisor.
    s/$/\nluck/
    x ; s/\(call_stack = [^\n]*\)/\1,generate_computer_move::get_luck/ ; x
    b get
    :generate_computer_move::get_luck

    s/\([01]*\)$/add::first_operand = \1/
    x ; s/\(call_stack = [^\n]*\)/\1,generate_computer_move::prepare_divisor_1/ ; x
    b set
    :generate_computer_move::prepare_divisor_1
    
    # 2
    s/$/\nadd::second_operand = 00000000000000000000000000000010/
    x ; s/\(call_stack = [^\n]*\)/\1,generate_computer_move::prepare_divisor_2/ ; x
    b set
    :generate_computer_move::prepare_divisor_2

    x ; s/\(call_stack = [^\n]*\)/\1,generate_computer_move::build_divisor/ ; x
    b add
    :generate_computer_move::build_divisor
  
    # Now let's perform yet another division
    s/\([01]*\)$/div::first_operand = \1/
    x ; s/\(call_stack = [^\n]*\)/\1,generate_computer_move::set_hit_dividend/ ; x
    b set
    :generate_computer_move::set_hit_dividend

    s/\([01]*\)$/div::second_operand = add::result/
    x ; s/\(call_stack = [^\n]*\)/\1,generate_computer_move::set_hit_divisor/ ; x
    b copy
    :generate_computer_move::set_hit_divisor

    x ; s/\(call_stack = [^\n]*\)/\1,generate_computer_move::perform_hit_div/ ; x
    b div
    :generate_computer_move::perform_hit_div
  
    # Write result
    s/$/\ngenerate_computer_move::cell_type = H/
    x ; s/\(call_stack = [^\n]*\)/\1,generate_computer_move::set_hit_type/ ; x
    b set
    :generate_computer_move::set_hit_type
    
    s/$/\ngenerate_computer_move::cell_number = div::div_result/
    x ; s/\(call_stack = [^\n]*\)/\1,generate_computer_move::set_hit_number/ ; x
    b copy
    :generate_computer_move::set_hit_number
    
    b return
  }
  
  :generate_computer_move::miss_result {
    s/\([01]*\) \([01]*\)\n\([01]*\) \([01]*\)$/\1\2\n\3\4/

    # 2*healthy_cells + healthy_cells*luck
    s/\([01]*\)$/add::second_operand = \1/
    x ; s/\(call_stack = [^\n]*\)/\1,generate_computer_move::prepare_miss_sub_1/ ; x
    b set
    :generate_computer_move::prepare_miss_sub_1
    
    # limited random number
    s/\([01]*\)$/add::first_operand = \1/
    x ; s/\(call_stack = [^\n]*\)/\1,generate_computer_move::prepare_miss_sub_2/ ; x
    b set
    :generate_computer_move::prepare_miss_sub_2

    x ; s/\(call_stack = [^\n]*\)/\1,generate_computer_move::build_dividend/ ; x
    b sub
    :generate_computer_move::build_dividend
      
    s/$/\nadd::result/
    x ; s/\(call_stack = [^\n]*\)/\1,generate_computer_move::get_miss_cell_number/ ; x
    b get
    :generate_computer_move::get_miss_cell_number

    # Write result
    s/\([01]*\)[01]$/\ngenerate_computer_move::cell_number = 0\1/
    x ; s/\(call_stack = [^\n]*\)/\1,generate_computer_move::set_miss_number/ ; x
    b set
    :generate_computer_move::set_miss_number
    
    s/$/\ngenerate_computer_move::cell_type = ·/
    x ; s/\(call_stack = [^\n]*\)/\1,generate_computer_move::set_miss_type/ ; x
    b set
    :generate_computer_move::set_miss_type

    b return
  }
}

# Computer move
# 1. Redraw the field
# 2. Generate a cell to shoot
# 3. Shoot in this cell
# 4. Handle hit/miss and transform field::player variable according to it
# 5. Log the last move
# 6. Decide who moves next
:computer_move {
  x ; s/\(call_stack = [^\n]*\)/\1,computer_move::draw/ ; x
  b draw
  :computer_move::draw

  # Generate computer move: cell type (full or empty) and number of the cell
  x ; s/\(call_stack = [^\n]*\)/\1,computer_move::generate_move/ ; x
  b generate_computer_move
  :computer_move::generate_move

  # Calculate the real coordinate based on generated move: number from 0 to 99
  x ; s/\(call_stack = [^\n]*\)/\1,computer_move::calculate_coordinates/ ; x
  b reverse_convert_coordinates
  :computer_move::calculate_coordinates

  s/$/\ngenerate_computer_move::cell_type/
  x ; s/\(call_stack = [^\n]*\)/\1,computer_move::get_ct/ ; x
  b get
  :computer_move::get_ct

  /H$/ {
    s/[^\n]*$/last_action_log/
    x ; s/\(call_stack = [^\n]*\)/\1,computer_move::hit_get_log/ ; x
    b get
    :computer_move::hit_get_log
  
    # get the human-readable coordinates
    s/$/\nreverse_convert_coordinates::result_string/
    x ; s/\(call_stack = [^\n]*\)/\1,computer_move::get_hit_coordinates/ ; x
    b get
    :computer_move::get_hit_coordinates
      
    s/\([^\n]*\)\n\([A-J][0-9]\)$/\nlast_action_log = \1_\2! Hit ya!/ 
    x ; s/\(call_stack = [^\n]*\)/\1,computer_move::hit_set_log/ ; x
    b set
    :computer_move::hit_set_log
   
    # Change symbol in a player field
    s/$/\nset_symbol::symbol = D/
    x ; s/\(call_stack = [^\n]*\)/\1,computer_move::set_hit_symbol/ ; x
    b set
    :computer_move::set_hit_symbol
    
    s/$/\nset_symbol::number = reverse_convert_coordinates::result_number/
    x ; s/\(call_stack = [^\n]*\)/\1,computer_move::set_hit_number/ ; x
    b copy
    :computer_move::set_hit_number

    s/$/\nset_symbol::string = field::player/
    x ; s/\(call_stack = [^\n]*\)/\1,computer_move::set_hit_string/ ; x
    b copy
    :computer_move::set_hit_string

    # Perform player field change
    x ; s/\(call_stack = [^\n]*\)/\1,computer_move::change_hit_string/ ; x
    b set_symbol 
    :computer_move::change_hit_string

    s/$/\nfield::player = set_symbol::result/
    x ; s/\(call_stack = [^\n]*\)/\1,computer_move::perform_hit/ ; x
    b copy
    :computer_move::perform_hit

    # make analysis
    s/$/\nanalyze_ship_state::coordinate = reverse_convert_coordinates::result_number/
    x ; s/\(call_stack = [^\n]*\)/\1,computer_move::prepare_analysis_coordinate/ ; x
    b copy
    :computer_move::prepare_analysis_coordinate
    
    s/$/\nanalyze_ship_state::ships = field::player_ships/
    x ; s/\(call_stack = [^\n]*\)/\1,computer_move::prepare_analysis_ships/ ; x
    b copy
    :computer_move::prepare_analysis_ships
       
    s/$/\nanalyze_ship_state::field = field::player/
    x ; s/\(call_stack = [^\n]*\)/\1,computer_move::prepare_analysis_field/ ; x
    b copy
    :computer_move::prepare_analysis_field

    x ; s/\(call_stack = [^\n]*\)/\1,computer_move::analysis/ ; x
    b analyze_ship_state
    :computer_move::analysis

    s/$/\nanalyze_ship_state::result/
    x ; s/\(call_stack = [^\n]*\)/\1,computer_move::get_analysis_result/ ; x
    b get
    :computer_move::get_analysis_result

    # Mark diagonal cross (common hit)
    s/$/\nmark::coordinates = reverse_convert_coordinates::result_number/
    x ; s/\(call_stack = [^\n]*\)/\1,computer_move::prepare_mark_coordinates/ ; x
    b copy
    :computer_move::prepare_mark_coordinates

    s/$/\nmark::field = field::player/
    x ; s/\(call_stack = [^\n]*\)/\1,computer_move::prepare_mark_field/ ; x
    b copy
    :computer_move::prepare_mark_field

    x ; s/\(call_stack = [^\n]*\)/\1,computer_move::mark_diagonal_cross/ ; x
    b mark_diagonal_cross
    :computer_move::mark_diagonal_cross

    s/$/\nfield::player = mark::field/
    x ; s/\(call_stack = [^\n]*\)/\1,computer_move::set_diagonal_cross/ ; x
    b copy
    :computer_move::set_diagonal_cross
    
    /sunk$/ {
      s/\n*sunk$//
  
      # Update player field
      s/$/\nmark::field = field::player/
      x ; s/\(call_stack = [^\n]*\)/\1,computer_move::update_before_sink/ ; x
      b copy
      :computer_move::update_before_sink
    
      x ; s/\(call_stack = [^\n]*\)/\1,computer_move::sink_ship/ ; x
      b sink_player_ship
      :computer_move::sink_ship
      
      # Get the ship cells
      s/$/\nmark::coordinates/
      x ; s/\(call_stack = [^\n]*\)/\1,computer_move::get_hit_cell/ ; x
      b get
      :computer_move::get_hit_cell
      
      s/$/\nfield::player_ships/
      x ; s/\(call_stack = [^\n]*\)/\1,computer_move::get_ship_list/ ; x
      b get
      :computer_move::get_ship_list
    
      s/$/\nmark::field = field::player/
      x ; s/\(call_stack = [^\n]*\)/\1,computer_move::prepare_mark_field_2/ ; x
      b copy
      :computer_move::prepare_mark_field_2
      
      s/\([^\n]*\)$/ \1/
      s/\([01]*\)\n[^\n]* \([01,]*\)\1\([01,]*\)[^\n]*$/,\2\1\3/
      s/\([01,]*\)$/mark::ship = \1/
      x ; s/\(call_stack = [^\n]*\)/\1,computer_move::set_ship_cells/ ; x
      b set
      :computer_move::set_ship_cells

      x ; s/\(call_stack = [^\n]*\)/\1,computer_move::mark_circle/ ; x
      b mark_circle  
      :computer_move::mark_circle
    
      # Change player field
      s/$/\nfield::player = mark::field/
      x ; s/\(call_stack = [^\n]*\)/\1,computer_move::update_after_sink/ ; x
      b copy
      :computer_move::update_after_sink

      x ; s/\(call_stack = [^\n]*\)/\1,computer_move::check_lose/ ; x
      b check_lose
      :computer_move::check_lose
    }

     b computer_move
  }

  # Miss handling
  /·$/ {
    s/[^\n]*$/last_action_log/
    x ; s/\(call_stack = [^\n]*\)/\1,computer_move::miss_get_log/ ; x
    b get
    :computer_move::miss_get_log
    
    # get the human-readable coordinates
    s/$/\nreverse_convert_coordinates::result_string/
    x ; s/\(call_stack = [^\n]*\)/\1,computer_move::get_miss_coordinates/ ; x
    b get
    :computer_move::get_miss_coordinates
  
    s/\([^\n]*\)\n\([A-J][0-9]\)$/\nlast_action_log = \1_\2! OK, I missed.../ 
    x ; s/\(call_stack = [^\n]*\)/\1,computer_move::miss_set_log/ ; x
    b set
    :computer_move::miss_set_log
 
    # Change symbol in a player field
    s/$/\nset_symbol::symbol = ~/
    x ; s/\(call_stack = [^\n]*\)/\1,computer_move::set_missed_symbol/ ; x
    b set
    :computer_move::set_missed_symbol
    
    s/$/\nset_symbol::number = reverse_convert_coordinates::result_number/
    x ; s/\(call_stack = [^\n]*\)/\1,computer_move::set_missed_number/ ; x
    b copy
    :computer_move::set_missed_number

    s/$/\nset_symbol::string = field::player/
    x ; s/\(call_stack = [^\n]*\)/\1,computer_move::set_missed_string/ ; x
    b copy
    :computer_move::set_missed_string

    # Perform player field change
    x ; s/\(call_stack = [^\n]*\)/\1,computer_move::change_missed_string/ ; x
    b set_symbol 
    :computer_move::change_missed_string

    s/$/\nfield::player = set_symbol::result/
    x ; s/\(call_stack = [^\n]*\)/\1,computer_move::perform_missed/ ; x
    b copy
    :computer_move::perform_missed

    b player_move
  }
}

# Easter egg
# Counts our sequential hits from the very beginning.
# In case we hit the enemy 10 times in a row, makes some fun :)
:easter
{
  s/$/\neaster/ 
  x ; s/\(call_stack = [^\n]*\)/\1,easter::get_shots/ ; x
  b get
  :easter::get_shots

  s/[01]\([01]*\)$/\10/

  /10000000000$/ {
    s/$/\nlast_action_log = Do you really want me to believe you're so lucky?_Big mistake, my friend! I'll show you how it feels to play with a cheater!/
    x ; s/\(call_stack = [^\n]*\)/\1,easter::log_set/ ; x
    b set
    :easter::log_set

    s/$/\nfield::player/ 
    x ; s/\(call_stack = [^\n]*\)/\1,easter::get_field/ ; x
    b get
    :easter::get_field
    
    s/·/~/g

    s/\([~H]*\)$/field::player = \1/ 
    x ; s/\(call_stack = [^\n]*\)/\1,easter::set_field/ ; x
    b set
    :easter::set_field
    
    b player_move::end_move
  }
  
  s/\([01]*\)$/easter = \1/ 
  x ; s/\(call_stack = [^\n]*\)/\1,easter::set_shots/ ; x
  b set
  :easter::set_shots
  b return
}

# Check win
# Analyze the state of the field::computer variable
# In case player have sunk all the computer ships, quit
:check_win
{
  x ; s/\(call_stack = [^\n]*\)/\1,check_win::check_easter/ ; x
  b easter
  :check_win::check_easter

  s/$/\nfield::computer/
  x ; s/\(call_stack = [^\n]*\)/\1,check_win::get_enemy_field/ ; x
  b get
  :check_win::get_enemy_field
  
  # If there is only water and sunk ships, player wins
  /\n[~X]*$/ {
    x ; s/\(call_stack = [^\n]*\)/\1,check_win::draw/ ; x
    b draw
    :check_win::draw
    s/^.*$/\nCongratulations, you've won!/
    p
    q
  }
  s/\n*[~HDX]*//
  b return 
}

# Check lose
# Analyze the state of the field::player variable
# In case computer have sunk all the player ships, quit
:check_lose
{
  s/$/\nfield::player/
  x ; s/\(call_stack = [^\n]*\)/\1,check_lose::get_player_field/ ; x
  b get
  :check_lose::get_player_field
  
  # If there is only unchecked cells, water and sunk ships, computer won
  /\n[·~X]*$/ {
    x ; s/\(call_stack = [^\n]*\)/\1,check_lose::draw/ ; x
    b draw
    :check_lose::draw
    s/^.*$/\nYou've lost. Better luck next time!/
    p
    q
  }
  s/\n*[~HDX]*//
  b return 
}


### VARIABLES ###
# Low level subprograms to work with variables.
# The only subprograms which use pattern space instead of variables.

# Set variable
# Gets the string like 'var = val' from the end of pattern space, sets the value of the variable 'var' to 'val'.
# Pops the last string from pattern space.
:set
  s/\([^\n]*\)$/:set\n\1/
  s/^\(.*\)\(:set\n[^\n]*\)$/\2\n\1/
  s/\n$//
  H
  s/^:set\n[^\n]*\n*//
  x
  s/^\(.*\)\n:set\n\([^\n]*\).*$/\2\n\1/
  s/^\([^\n= ]*\) = \([^\n]*\)\n\(.*\)\1 = [^\n]*\(.*\)$/\3\1 = \2\4/
  x
  b return

# Gets the string like 'var' from the end of pattern space, gets the value of the variable 'var'.
# Changes the last string in pattern space with this value.
:get
  s/\([^\n]*\)$/:get\n\1/
  s/^\(.*\)\(:get\n[^\n]*\)$/\2\n\1/
  s/\n$//
  H
  s/^:get\n[^\n]*\n*//
  x
  s/^\(.*\)\n:get\n\([^\n]*\).*$/\2\n\1/
  s/^\([^\n]*\)\n\(.*\)\1 = \([^\n]*\)/:get\n\3\n\2\1 = \3/
  H
  s/^:get\n[^\n]*\n\(.*\)$/\1/
  x
  s/^\n*\(.*\)\n:get\n\([^\n]*\).*$/\1\n\2/
  b return

# Gets the string like 'var1 = var2' from the end of pattern space, sets the value of the variable 'var1' to the value of the variable 'var2'.
# Pops the last string from pattern space.
:copy
{
  s/\([^\n]*\)$/:copy\n\1/
  s/^\(.*\)\(:copy\n[^\n]*\)$/\2\n\1/
  s/\n$//
  H
  s/^:copy\n[^\n]*\n*//
  x
  s/^\(.*\)\n:copy\n\([^\n]*\).*$/\2\n\1/
  s/^\([^ ]*\) = \([^\n]*\)\n\(.*\)\2 = \([^\n]*\)/\1 = \4\n\3\2 = \4/
  s/^\([^ ]*\) = \([^\n]*\)\n\(.*\)\1 = [^\n]*/\3\1 = \2/
  x
  b return
}


### STRINGS ###
# Functions to work with strings

# Converts field coordinates to the binary number of the cell.
# E.g. 'A0' -> '0000000' (0) ; 'J9' -> '1100011' (99)
# Gets the coordinates from convert_coordinates::coordinates
# Puts the result into convert_coordinates::result
:convert_coordinates
{
  # Coordinates reading
  s/$/\nconvert_coordinates::coordinates/
  x ; s/\(call_stack = [^\n]*\)/\1,convert_coordinates::get_coordinates/ ; x
  b get
  :convert_coordinates::get_coordinates

  s/\([A-Ja-j]\) *\([0-9]\)$/\1\n\2/

  # Convert digit
  s/0$/0000000/ ; s/1$/0000001/ ; s/2$/0000010/ ; s/3$/0000011/ ; s/4$/0000100/ ; s/5$/0000101/ ; s/6$/0000110/ ; s/7$/0000111/ ; s/8$/0001000/ ; s/9$/0001001/
  s/\([^\n]*\)$/convert_coordinates::digit = \1/
  x ; s/\(call_stack = [^\n]*\)/\1,convert_coordinates::set_digit/ ; x
  b set
  :convert_coordinates::set_digit
 
  # Convert letter
  s/[Aa]$/0000000/ ; s/[Bb]$/0000001/ ; s/[Cc]$/0000010/ ; s/[Dd]$/0000011/ ; s/[Ee]$/0000100/ ; s/[Ff]$/0000101/ ; s/[Gg]$/0000110/ ; s/[Hh]$/0000111/ ; s/[Ii]$/0001000/ ; s/[Jj]$/0001001/
  s/\([^\n]*\)$/mul::first_operand = \1/
  x ; s/\(call_stack = [^\n]*\)/\1,convert_coordinates::set_letter/ ; x
  b set
  :convert_coordinates::set_letter

  # Prepare letter multiplication by 10.
  s/$/\n0001010/
  s/\([^\n]*\)$/mul::second_operand = \1/
  x ; s/\(call_stack = [^\n]*\)/\1,convert_coordinates::set_ten/ ; x
  b set
  :convert_coordinates::set_ten

  # Perform multiplication
  x ; s/\(call_stack = [^\n]*\)/\1,convert_coordinates::execute_mul/ ; x
  b mul
  :convert_coordinates::execute_mul

  # Prepare addition (letter*10 + digit)
  s/$/\nadd::first_operand = convert_coordinates::digit/
  x ; s/\(call_stack = [^\n]*\)/\1,convert_coordinates::set_add_1/ ; x
  b copy
  :convert_coordinates::set_add_1
  
  s/$/\nadd::second_operand = mul::result/
  x ; s/\(call_stack = [^\n]*\)/\1,convert_coordinates::set_add_2/ ; x
  b copy
  :convert_coordinates::set_add_2

  # Perform addition  
  x ; s/\(call_stack = [^\n]*\)/\1,convert_coordinates::execute_add/ ; x
  b add
  :convert_coordinates::execute_add
  
  # Write the result
  s/$/\nconvert_coordinates::result = add::result/
  x ; s/\(call_stack = [^\n]*\)/\1,convert_coordinates::result/ ; x
  b copy
  :convert_coordinates::result

  b return
}

# Reverse coordinate conversion
# Gets info from:
#   generate_computer_move::cell_type
#   generate_computer_move::cell_number 
#   field::player (we use it only for computer moves anyway)
# Puts the result into variables:
#   reverse_convert_coordinates::result_string – human-readable format (like A5 or G8)
#   reverse_convert_coordinates::result_number — the binary form of the result cell number
:reverse_convert_coordinates {
  s/$/\ngenerate_computer_move::cell_type/
  x ; s/\(call_stack = [^\n]*\)/\1,reverse_convert_coordinates::get_cell_type/ ; x
  b get
  :reverse_convert_coordinates::get_cell_type
  
  s/$/\ngenerate_computer_move::cell_number/
  x ; s/\(call_stack = [^\n]*\)/\1,reverse_convert_coordinates::get_cell_number/ ; x
  b get
  :reverse_convert_coordinates::get_cell_number

  # Truncate cell number: we need only 7 bits (at most)
  s/[01]*\([01]\{7\}\)$/\1/
  # Init two counters
  s/$/\n0000000\n0000000/

  s/$/\nfield::player/
  x ; s/\(call_stack = [^\n]*\)/\1,reverse_convert_coordinates::get_player_field/ ; x
  b get
  :reverse_convert_coordinates::get_player_field

  :reverse_convert_coordinates::cell_count_loop
    # Stop when the first counter equals cell_number
    # AND
    # the cell type is the same we search
    /\([·~HDX]\)\n\([01]*\)\n\2\n[01]*\n\1[·~HDX]*$/ b reverse_convert_coordinates::end_loop

    # Increment the first counter in case the first field symbol is the same as cell_type
    /\([·~HDX]\)\n[01]*\n[01]*\n[01]*\n\1[·~HDX]*$/ {
      /\n0*\n[01]*\n[·~HDX]*$/ {s/\(0*\)0\n\([01]*\)\n\([·~HDX]*\)$/\11\n\2\n\3/ ; b reverse_convert_coordinates::first_count_endloop; }
      :reverse_convert_coordinates::first_inc_loop ; s/1\(_*\)\n\([01]*\)\n\([·~HDX]*\)$/_\1\n\2\n\3/ ; /1_*\n[01]*\n[·~HDX]*$/ b reverse_convert_coordinates::first_inc_loop
      s/0\(_*\)\n\([01]*\)\n\([·~HDX]*\)$/1\1\n\2\n\3/
      :reverse_convert_coordinates::first_inc_reverseloop ; s/_\(_*\)\n\([01]*\)\n\([·~HDX]*\)$/0\1\n\2\n\3/ ; /_\n[01]*\n[·~HDX]*$/ b reverse_convert_coordinates::first_inc_reverseloop;
      :reverse_convert_coordinates::first_count_endloop
    }

    # Increment the second counter unconditionally
    /\n0*\n[·~HDX]*$/ {s/\(0*\)0\n\([·~HDX]*\)$/\11\n\2/ ; b reverse_convert_coordinates::second_count_endloop; }
    :reverse_convert_coordinates::second_inc_loop ; s/1\(_*\)\n\([·~HDX]*\)$/_\1\n\2/ ; /1_*\n[·~HDX]*$/ b reverse_convert_coordinates::second_inc_loop
    s/0\(_*\)\n\([·~HDX]*\)$/1\1\n\2/
    :reverse_convert_coordinates::second_inc_reverseloop ; s/_\(_*\)\n\([·~HDX]*\)$/0\1\n\2/ ; /_\n[·~HDX]*$/ b reverse_convert_coordinates::second_inc_reverseloop;
    :reverse_convert_coordinates::second_count_endloop
     
    # Delete the first field symbol
    s/[·~HDX]\([·~HDX]*\)$/\1/
    b reverse_convert_coordinates::cell_count_loop
  :reverse_convert_coordinates::end_loop

  # Clear artifacts: leave only the cell number
  s/[·~HDX]\n[01]*\n[01]*\n\([01]*\)\n[·~HDX]*$/\1/

  # Save the result cell
  s/\([01]*\)$/\1\nreverse_convert_coordinates::result_number = \1/
  x ; s/\(call_stack = [^\n]*\)/\1,reverse_convert_coordinates::save_result_number/ ; x
  b set
  :reverse_convert_coordinates::save_result_number
  
  # Perform division by 10 to get human-readable coordinates
  s/\([01]*\)$/div::first_operand = \1/
  x ; s/\(call_stack = [^\n]*\)/\1,reverse_convert_coordinates::prepare_coordinate_div_1/ ; x
  b set
  :reverse_convert_coordinates::prepare_coordinate_div_1

  s/\([01]*\)$/div::second_operand = 0001010/
  x ; s/\(call_stack = [^\n]*\)/\1,reverse_convert_coordinates::prepare_coordinate_div_2/ ; x
  b copy
  :reverse_convert_coordinates::prepare_coordinate_div_2

  x ; s/\(call_stack = [^\n]*\)/\1,reverse_convert_coordinates::perform_coordinate_div/ ; x
  b div
  :reverse_convert_coordinates::perform_coordinate_div

  s/$/\ndiv::div_result/
  x ; s/\(call_stack = [^\n]*\)/\1,reverse_convert_coordinates::get_y_coordinate/ ; x
  b get
  :reverse_convert_coordinates::get_y_coordinate
  
  s/$/\ndiv::mod_result/
  x ; s/\(call_stack = [^\n]*\)/\1,reverse_convert_coordinates::get_x_coordinate/ ; x
  b get
  :reverse_convert_coordinates::get_x_coordinate

  # Convert letter
  s/0000000\n\([01]*\)$/A\n\1/ ; s/0000001\n\([01]*\)$/B\n\1/ ; s/0000010\n\([01]*\)$/C\n\1/ ; s/0000011\n\([01]*\)$/D\n\1/ ; s/0000100\n\([01]*\)$/E\n\1/ ; s/0000101\n\([01]*\)$/F\n\1/ ; s/0000110\n\([01]*\)$/G\n\1/ ; s/0000111\n\([01]*\)$/H\n\1/ ; s/0001000\n\([01]*\)$/I\n\1/ ; s/0001001\n\([01]*\)$/J\n\1/ 
  
  # Convert digit
  s/\n0000000$/0/ ; s/\n0000001$/1/ ; s/\n0000010$/2/ ; s/\n0000011$/3/ ; s/\n0000100$/4/ ; s/\n0000101$/5/ ; s/\n0000110$/6/ ; s/\n0000111$/7/ ; s/\n0001000$/8/ ; s/\n0001001$/9/

  # Save human-readable coordinates
  s/\([A-J][0-9]\)$/reverse_convert_coordinates::result_string = \1/
  x ; s/\(call_stack = [^\n]*\)/\1,reverse_convert_coordinates::save_result_string/ ; x
  b set
  :reverse_convert_coordinates::save_result_string
  
  b return
}

# Getting n-th symbol from the string
# Gets the string from get_symbol::string, gets the number from get_symbol::number
# Puts the result into get_symbol::result
:get_symbol
{
  # Get string
  s/$/\nget_symbol::string/
  x ; s/\(call_stack = [^\n]*\)/\1,get_symbol::get_string/ ; x
  b get
  :get_symbol::get_string

  # Get number (binary form)
  s/$/\nget_symbol::number/
  x ; s/\(call_stack = [^\n]*\)/\1,get_symbol::get_number/ ; x
  b get
  :get_symbol::get_number
 
  # Copy the number and initialize the counter with m-bit zero (m is a bit number of the symbol number)
  s/\([01]*\)$/\1\n\1/
  :get_symbol::init_loop
  s/1\(0*\)$/0\1/
  /10*$/ b get_symbol::init_loop

  # Counting symbol: loop until counter < number
  :get_symbol::count_loop
  /\([01]*\)\n\1$/ b get_symbol::end_loop
  # Delete the first symbol of string
  s/[^\n]\([^\n]*\)\n\([01]*\)\n\([01]*\)$/\1\n\2\n\3/
  # Inlined counter increment: it is shorter than using add
  /\n0*$/ {s/\(0*\)0$/\11/ ; b get_symbol::count_loop; }
  :get_symbol::inc_loop ; s/1\(_*\)$/_\1/ ; /1_*$/ b get_symbol::inc_loop 
  s/0\(_*\)$/1\1/
  :get_symbol::inc_reverseloop ; s/_\(_*\)$/0\1/ ; /_$/ b get_symbol::inc_reverseloop;

  b get_symbol::count_loop
  :get_symbol::end_loop

  # Clean artifacts, get the symbol and write it
  s/\([^\n]\)[^\n]*\n[01]*\n[01]*$/get_symbol::result = \1/
  x ; s/\(call_stack = [^\n]*\)/\1,get_symbol::result/ ; x
  b set
  :get_symbol::result
  b return
}

# Replace n-th symbol in the string with another one
# Gets:
#   string from set_symbol::string;
#   new symbol from set_symbol::symbol.
#   number from set_symbol::number;
# Puts the result into set_symbol::result
:set_symbol
{
  # Get string and place a space before it
  s/$/\nset_symbol::string/
  x ; s/\(call_stack = [^\n]*\)/\1,set_symbol::get_string/ ; x
  b get
  :set_symbol::get_string
  s/\([^\n]*\)$/ \1/

  # Get symbol
  s/$/\nset_symbol::symbol/
  x ; s/\(call_stack = [^\n]*\)/\1,set_symbol::get_symbol/ ; x
  b get
  :set_symbol::get_symbol
   
  # Get number (binary form)
  s/$/\nset_symbol::number/
  x ; s/\(call_stack = [^\n]*\)/\1,set_symbol::get_number/ ; x
  b get
  :set_symbol::get_number
 
  # Copy the number and initialize the counter with m-bit zero (m is a bit number of the symbol number)
  s/\([01]*\)$/\1\n\1/
  :set_symbol::init_loop
  s/1\(0*\)$/0\1/
  /10*$/ b set_symbol::init_loop

  # Counting symbol: loop until counter < number
  :set_symbol::count_loop
  /\([01]*\)\n\1$/ b set_symbol::end_loop
  # Move the space after the next string symbol
  s/\([^\n ]*\) \([^\n]\)\([^\n]*\)\n\([^\n]\)\n\([01]*\)\n\([01]*\)$/\1\2 \3\n\4\n\5\n\6/
  # Inlined counter increment: it is shorter than using add
  /\n0*$/ {s/\(0*\)0$/\11/ ; b set_symbol::count_loop; }
  :set_symbol::inc_loop ; s/1\(_*\)$/_\1/ ; /1_*$/ b set_symbol::inc_loop 
  s/0\(_*\)$/1\1/
  :set_symbol::inc_reverseloop ; s/_\(_*\)$/0\1/ ; /_$/ b set_symbol::inc_reverseloop;

  b set_symbol::count_loop
  :set_symbol::end_loop

  # Replace symbol and clean artifacts  
  s/\([^\n ]*\) [^\n]\([^\n]*\)\n\([^\n]\)\n[01]*\n[01]*$/\1\3\2/

  # Write the new string 
  s/\([^\n]*\)$/set_symbol::result = \1/
  x ; s/\(call_stack = [^\n]*\)/\1,set_symbol::result/ ; x
  b set
  :set_symbol::result
  b return
}

# Field drawing
# Draws two standard fields and prints the last actions.
# Gets the parameters from field::player, field::suggestions and last_action_log
:draw
{
  # Clear pattern space
  s/^.*$//

  # Get fields
  s/$/\nfield::player/
  x ; s/\(call_stack = [^\n]*\)/\1,draw::get_field1/ ; x
  b get
  :draw::get_field1

  s/$/\nfield::suggestions/
  x ; s/\(call_stack = [^\n]*\)/\1,draw::get_field2/ ; x
  b get
  :draw::get_field2
 
  # Putting spaces (beautify a bit)
  s/\([·~HDX]\)/\1 /g

  # Not very elegant but brutally clear: get every 20 fields from each field string (10 significant and 10 spaces), delete them from the string and put them into the end according to the letter coordinate. Repeat 10 times.
  s/$/\n   | \c[[1m0 1 2 3 4 5 6 7 8 9\c[[0m            | \c[[1m0 1 2 3 4 5 6 7 8 9\c[[0m/
  s/$/\n---+--------------------         ---+--------------------/
  s/^\([·~HDX ]\{20\}\)\([·~HDX ]*\)\n\([·~HDX ]\{20\}\)\([·~HDX ]*\)\n\(.*\)$/\2\n\4\n\5\
 \c[[1mA\c[[0m | \1         \c[[1mA\c[[0m | \3/
  s/^\([·~HDX ]\{20\}\)\([·~HDX ]*\)\n\([·~HDX ]\{20\}\)\([·~HDX ]*\)\n\(.*\)$/\2\n\4\n\5\
 \c[[1mB\c[[0m | \1         \c[[1mB\c[[0m | \3/
  s/^\([·~HDX ]\{20\}\)\([·~HDX ]*\)\n\([·~HDX ]\{20\}\)\([·~HDX ]*\)\n\(.*\)$/\2\n\4\n\5\
 \c[[1mC\c[[0m | \1         \c[[1mC\c[[0m | \3/
  s/^\([·~HDX ]\{20\}\)\([·~HDX ]*\)\n\([·~HDX ]\{20\}\)\([·~HDX ]*\)\n\(.*\)$/\2\n\4\n\5\
 \c[[1mD\c[[0m | \1         \c[[1mD\c[[0m | \3/
  s/^\([·~HDX ]\{20\}\)\([·~HDX ]*\)\n\([·~HDX ]\{20\}\)\([·~HDX ]*\)\n\(.*\)$/\2\n\4\n\5\
 \c[[1mE\c[[0m | \1         \c[[1mE\c[[0m | \3/
  s/^\([·~HDX ]\{20\}\)\([·~HDX ]*\)\n\([·~HDX ]\{20\}\)\([·~HDX ]*\)\n\(.*\)$/\2\n\4\n\5\
 \c[[1mF\c[[0m | \1         \c[[1mF\c[[0m | \3/
  s/^\([·~HDX ]\{20\}\)\([·~HDX ]*\)\n\([·~HDX ]\{20\}\)\([·~HDX ]*\)\n\(.*\)$/\2\n\4\n\5\
 \c[[1mG\c[[0m | \1         \c[[1mG\c[[0m | \3/
  s/^\([·~HDX ]\{20\}\)\([·~HDX ]*\)\n\([·~HDX ]\{20\}\)\([·~HDX ]*\)\n\(.*\)$/\2\n\4\n\5\
 \c[[1mH\c[[0m | \1         \c[[1mH\c[[0m | \3/
  s/^\([·~HDX ]\{20\}\)\([·~HDX ]*\)\n\([·~HDX ]\{20\}\)\([·~HDX ]*\)\n\(.*\)$/\2\n\4\n\5\
 \c[[1mI\c[[0m | \1         \c[[1mI\c[[0m | \3/
  s/^\([·~HDX ]\{20\}\)\n\([·~HDX ]\{20\}\)\n\(.*\)$/\3\
 \c[[1mJ\c[[0m | \1         \c[[1mJ\c[[0m | \2/

  # Colorize
  s/ D/ \c[[33mD\c[[0m/g
  s/ X/ \c[[31mX\c[[0m/g
  s/ H/ \c[[32mH\c[[0m/g
  s/ ~/ \c[[34m~\c[[0m/g

  # Get the last actions log
  s/$/\n\nlast_action_log/
  x ; s/\(call_stack = [^\n]*\)/\1,draw::get_log/ ; x
  b get
  :draw::get_log

  # Log formatting
  s/_/\n/g 
  # Add yet another line
  s/$/\n/
  s/^/\c[[H\c[[J           === Sed Battleship by Red Void ===\n\n/
  # Print fields
  p
  # Clear pattern space one more time
  s/^.*$//

  b return
}


### MATH ###
# Subprograms to perform arithmetics

# Addition
# Gets the operands from add::first_operand and add::second_operand
# Puts the result to add::result
:add
{
  # Operands reading
  s/$/\nadd::first_operand/
  x ; s/\(call_stack = [^\n]*\)/\1,add::get1/ ; x
  b get
  :add::get1
  
  s/$/\nadd::second_operand/
  x ; s/\(call_stack = [^\n]*\)/\1,add::get2/ ; x
  b get
  :add::get2

  # Prepare variables to add
  s/\([01]*\)\n\([01]*\)$/\1 \n\2/
  
  # Addition loop: add the second operand bit by bit
  :add::loop
    # Skip adding bit if it is zero
    /0$/ b add::continueloop
    # Replace the "1" symbols in the end with "_"
    :add::_replaceloop
      s/\([01]*\)1\(_*\) \([01]*\)\n\([01]*\)$/\1_\2 \3\n\4/
      /[01]*1_* [01]*\n[01]*$/ b add::_replaceloop
    # Replace the "0" symbol before the "_"-tail with "1"
    s/\([01]*\)0\(_*\) \([01]*\)\n\([01]*\)$/\11\2 \3\n\4/
    # Replace the "_" symbols with "1"
    :add::_reversereplaceloop
      s/\([01]*\)_\([^\n ]*\) \([01]*\)\n\([01]*\)$/\10\2 \3\n\4/
      /[01]*_[01 _]*\n[01]*$/ b add::_reversereplaceloop
    :add::continueloop
    # Save the current bit
    s/\([01]*\)\([01]\) \([01]*\)\n\([01]*\).$/\1 \2\3\n\4/
  /[01]$/ b add::loop  

  # Write the result
  s/ \([^\n]*\)\n$/add::result = \1/
  x ; s/\(call_stack = [^\n]*\)/\1,add::result/ ; x
  b set
  :add::result
  
  b return
}


# Subtraction
# Gets the operands from add::first_operand (minuend) and add::second_operand (subtrahend)
# Puts the result to add::result 
:sub
{
  # The main idea is to transform the subtrahend (s) into -s and then use the addition:
  # m - s = m + (-s)
  # The transformation is based on the overflow:
  # (-s) + s = 0 -> -s = ~s + 1
  # E.g.:
  # s = 101110
  # ~s = 010001
  # -s = ~s + 1 = 010010

  # Read the subtrahend
  s/$/\nadd::second_operand/
  x ; s/\(call_stack = [^\n]*\)/\1,sub::get1/ ; x
  b get
  :sub::get1

  # Bit inversion: s -> ~s
  :sub::1_loop
    s/1\([0_]*\)$/_\1/
    /1[0_]*$/ b sub::1_loop
  :sub::01loop
    s/0\([_1]*\)$/1\1/
    /0[_1]*$/ b sub::01loop
  :sub::_0loop
    s/_\([10]*\)$/0\1/
    /_[10]*$/ b sub::_0loop

  # Increment: ~s -> ~s + 1
  :sub::_replaceloop
    s/\([01]*\)1\(_*\)$/\1_\2/
    /[01]*1_*$/ b sub::_replaceloop
  s/0\(_*\)$/1\1/
  :sub::_reversereplaceloop
    s/\([01]*\)_\([^\n ]*\)$/\10\2/
    /[01]*_[01_]*$/ b sub::_reversereplaceloop

  # Write transformed subtrahend as an addend
  s/\([^\n]*\)$/add::second_operand = \1/
  x ; s/\(call_stack = [^\n]*\)/\1,sub::set1/ ; x
  b set
  :sub::set1

  # Performing the addition
  b add
}


# Multiplication
# Gets the operands from mul::first_operand and mul::second_operand 
# Puts the result to mul::result
:mul
{
  # Reading the factors
  s/$/\nmul::first_operand/
  x ; s/\(call_stack = [^\n]*\)/\1,mul::get1/ ; x
  b get
  :mul::get1
  
  s/$/\nmul::second_operand/
  x ; s/\(call_stack = [^\n]*\)/\1,mul::get2/ ; x
  b get
  :mul::get2
  
  # Initialize the result with zero (considering bit number), save it into the last line
  s/\([01]*\)$/\1\n\1/
  :mul::init_loop
  s/1\(0*\)$/0\1/
  /10*$/ b mul::init_loop

  # Multiplication loop: multiply by the second factor bit by bit 
  :mul::loop
    /0\n[01]*$/ b mul::shift

    # Prepare for addition. Set the first addend: the current result
    s/\([01]*\)$/\1\nadd::first_operand = \1/
    x ; s/\(call_stack = [^\n]*\)/\1,mul::prepare_intermediate_result_1/ ; x
    b set
    :mul::prepare_intermediate_result_1

    # Set the second addend: the current first factor
    s/\([01]*\)\n\([01]*\)\n\([01]*\)$/\1\n\2\n\3\nadd::second_operand = \1/
    x ; s/\(call_stack = [^\n]*\)/\1,mul::prepare_intermediate_result_2/ ; x
    b set
    :mul::prepare_intermediate_result_2

    # Perform the addition
    x ; s/\(call_stack = [^\n]*\)/\1,mul::calculate_intermediate_result/ ; x
    b add
    :mul::calculate_intermediate_result

    # Update the current result
    s/[01]*$/add::result/
    x ; s/\(call_stack = [^\n]*\)/\1,mul::get_intermediate_result/ ; x
    b get
    :mul::get_intermediate_result
      
    :mul::shift
    # Shift the first factor by one bit (multiply it by 2)
    s/[01]\([01]*\)\n\([01]*\)\n\([01]*\)$/\10\n\2\n\3/
    
    # Delete the last bit of the second factor
    s/\([01]*\)[01]\n\([01]*\)$/\1\n\2/
    /\n\n[01]*$/ b mul::end_loop
    b mul::loop
  
  :mul::end_loop

  # Write the final result
  s/\([^\n]*\)$/mul::result = \1/
  x ; s/\(call_stack = [^\n]*\)/\1,mul::result/ ; x
  b set
  :mul::result

  # Clean the artifacts (could be made in the upper commands, it's just for the clarity)
  s/\n*[01]*\n$//
  
  b return
}


# Division
# Gets the operands from div::first_operand and div::second_operand 
# Puts the result to div::div_result (quotient) and div::mod_result (remainder)
:div
{
  # Reading the dividend and the divisor
  s/$/\ndiv::first_operand/
  x ; s/\(call_stack = [^\n]*\)/\1,div::get1/ ; x
  b get
  :div::get1
  
  s/$/\ndiv::second_operand/
  x ; s/\(call_stack = [^\n]*\)/\1,div::get2/ ; x
  b get
  :div::get2

  # Initialize the quotient and the remainder.
  # Also, determine the first dividend bit: put space after its "0"-head
  s/\(0*\)\([01]*\)\n\([01]*\)$/\1 \2\n\3\n\1 \2\n\1\2/
  # Bit number is good, let's zero the quotient and the remainder
  :div::init_loop
    # Change the next "1" to "0" in the quotient
    s/\([0 ]*\)1\([01]*\)\n\([01]*\)$/\10\2\n\3/
    # ... then in the remainder.
    s/\(0*\)1\([01]*\)$/\10\2/
    # Continue the loop in case we still have "1" symbols
    /0*1[01]*\n[01]*$/ b div::init_loop
    /0*1[01]*$/ b div::init_loop

  # The main division loop
  :div::loop
    # Multiply the remainder by 2 and set its rightmost bit as the leftmost bit of the dividend
    s/\([01]*\) \([01]\)\([01]*\)\n\([01]*\)\n\([01 ]*\)\n[01]\([01]*\)$/\1 \2\3\n\4\n\5\n\6\2/
   
    # Comparison procedure of the remainder and the divisor.
    # First of all, copy both numbers
    s/\([01]*\)\n\([01 ]*\)\n\([01]*\)$/\1\n\2\n\3\n \1\n \3/
  
    # In case the remainder equals the divisor we need to clear the artifacts and move to the subtraction
    /\([01 ]*\)\n\1$/ { s/\n[01 ]*\n[01 ]*$// ; b div::sub ; }

    # The same situation is in case the remainder is greater than the divisor.
    # Otherwise we clean the artifacts and skip the subtraction
    :div::compare_loop
      s/[01]* \([01]\)\([01]*\)\n[01]* \([01]\)\([01]*\)$/\1 \2\n\3 \4/
      /0 [01]*\n1 [01]*$/ { s/\n[01 ]*\n[01 ]*$// ; b div::sub ; }
      /1 [01]*\n0 [01]*$/ { s/\n[01 ]*\n[01 ]*$// ; b div::subend ; }
      b div::compare_loop

    # Subtraction loop
    :div::sub
      # Set the operands
      # minuend := remainder
      s/\([^\n]*\)$/\1\nadd::first_operand = \1/
      x ; s/\(call_stack = [^\n]*\)/\1,div::prepare_sub_1/ ; x
      b set
      :div::prepare_sub_1

      # subtrahend := divisor
      s/\([01]*\)\n\([01 ]*\)\n\([01]*\)$/\1\n\2\n\3\nadd::second_operand = \1/
      x ; s/\(call_stack = [^\n]*\)/\1,div::prepare_sub_2/ ; x
      b set
      :div::prepare_sub_2

      # Perform the subtraction 
      x ; s/\(call_stack = [^\n]*\)/\1,div::execute_sub/ ; x
      b sub
      :div::execute_sub
 
      # Set the new remainder value
      s/[01]*$/add::result/
      x ; s/\(call_stack = [^\n]*\)/\1,div::set_remainder/ ; x
      b get
      :div::set_remainder

      # Set the appropriate bit of the quotient to 1
      s/ 0\([01]*\)\n\([01]*\)$/ 1\1\n\2/

    :div::subend
    # Save one bit of the dividend and the quotient, continue the main loop until we still have bits
    s/\([01]*\) \([01]\)\([01]*\)\n\([01]*\)\n\([01]*\) \([01]\)\([01]*\)\n\([01]*\)$/\1\2 \3\n\4\n\5\6 \7\n\8/
    /[01]\n[01]*$/ b div::loop

  # Delete the space from the quotient
  s/ \n\([01]*\)$/\n\1/

  # Clean the artifacts
  s/[01 ]*\n[01]*\n\([01]*\)\n\([01]*\)$/\1\n\2/

  # Set results
  s/\([01]*\)$/div::mod_result = \1/
  x ; s/\(call_stack = [^\n]*\)/\1,div::result_1/ ; x
  b set
  :div::result_1

  s/\([^\n]*\)$/div::div_result = \1/
  x ; s/\(call_stack = [^\n]*\)/\1,div::result_2/ ; x
  b set
  :div::result_2

  b return
} 


### RANDOM ###
# Random number primitives

# Linear congruential random number generator
# Gets parameters from rng::A, rng::C and rng::M.
# Gets current state from rng::current_state
# Puts the next random number into rng::current_state
:rng
{
  # Set multiplication operands
  s/$/\nmul::first_operand = rng::A/
  x ; s/\(call_stack = [^\n]*\)/\1,rng::mul_set_1/ ; x
  b copy
  :rng::mul_set_1

  s/$/\nmul::second_operand = rng::current_state/
  x ; s/\(call_stack = [^\n]*\)/\1,rng::mul_set_2/ ; x
  b copy
  :rng::mul_set_2

  # Perform multiplication
  x ; s/\(call_stack = [^\n]*\)/\1,rng::execute_mul/ ; x
  b mul
  :rng::execute_mul
  
  # Set addition operands
  s/$/\nadd::first_operand = mul::result/
  x ; s/\(call_stack = [^\n]*\)/\1,rng::add_set_1/ ; x
  b copy
  :rng::add_set_1

  s/$/\nadd::second_operand = rng::C/
  x ; s/\(call_stack = [^\n]*\)/\1,rng::add_set_2/ ; x 
  b copy
  :rng::add_set_2

  # Perform addition
  x ; s/\(call_stack = [^\n]*\)/\1,rng::execute_add/ ; x
  b add
  :rng::execute_add
 
  # Set division operands
  s/$/\ndiv::first_operand = add::result/
  x ; s/\(call_stack = [^\n]*\)/\1,rng::div_set_1/ ; x
  b copy
  :rng::div_set_1

  s/$/\ndiv::second_operand = rng::M/
  x ; s/\(call_stack = [^\n]*\)/\1,rng::div_set_2/ ; x
  b copy
  :rng::div_set_2

  # Perform division and get the final result
  x ; s/\(call_stack = [^\n]*\)/\1,rng::execute_div/ ; x
  b div
  :rng::execute_div
 
  # Set the new random number into the current state
  s/$/\nrng::current_state = div::mod_result/
  x ; s/\(call_stack = [^\n]*\)/\1,rng::result/ ; x
  b copy
  :rng::result

  b return
}


# Random seed procedure
# Gets parameters from field::player_ships and luck.
# Puts the random seed into rng::current_state
:rng_seed {
  s/$/\nfield::player_ships/
  x ; s/\(call_stack = [^\n]*\)/\1,rng_seed::get_rng_seed_parts_1/ ; x
  b get
  :rng_seed::get_rng_seed_parts_1

  # Lossless compression: 100 -> 76 bits
  # The result string completely determines the ship positioning
  s/\([^01,][01]\{6\}0\)\(,[01]\{6\}1\)[^ ]*/\11/g
  s/\([^01,][01]\{6\}1\)\(,[01]\{6\}0\)[^ ]*/\11/g
  s/\([^01,][01]*\),[01,]*/\10/g
  
  s/$/\nluck/
  x ; s/\(call_stack = [^\n]*\)/\1,rng_seed::get_rng_seed_parts_2/ ; x
  b get
  :rng_seed::get_rng_seed_parts_2
   
  # Lossy compression: 32 -> 4 bits
  # However we won't have luck > 15, so it is also practically lossless
  s/[01]*\([01]\{4\}\)$/\1/
  s/[\n ]//g

  s/$/\nrng::M/
  x ; s/\(call_stack = [^\n]*\)/\1,rng_seed::get_rng_seed_parts_3/ ; x
  b get
  :rng_seed::get_rng_seed_parts_3

  # We have 80 bits in total in the dividend and only 32 — in the divisor
  # That's why we need to add 48 zeros
  s/\([01]*\)\n\([01]*\)$/div::first_operand = \1\ndiv::second_operand = 000000000000000000000000000000000000000000000000\2/
  x ; s/\(call_stack = [^\n]*\)/\1,rng_seed::set_divisor/ ; x
  b set
  :rng_seed::set_divisor

  x ; s/\(call_stack = [^\n]*\)/\1,rng_seed::set_dividend/ ; x
  b set
  :rng_seed::set_dividend

  x ; s/\(call_stack = [^\n]*\)/\1,rng_seed::perform_division/ ; x
  b div
  :rng_seed::perform_division
 
  s/^.*$/div::mod_result/
  x ; s/\(call_stack = [^\n]*\)/\1,rng_seed::get_raw_seed/ ; x
  b get
  :rng_seed::get_raw_seed
 
  s/.*\([01]\{32\}\)$/rng::current_state = \1/
  x ; s/\(call_stack = [^\n]*\)/\1,rng_seed::set_seed/ ; x
  b set 
  :rng_seed::set_seed

  b return
}


### MISC ###

# Return handler
# This function manages execution process.
# Pops the last element from the call_stack variable and jumps to the position its value represents
:return
{
  x 
  /call_stack = [^\n]*,sub::get1\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b sub::get1 ; }
  /call_stack = [^\n]*,sub::set1\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b sub::set1 ; }
  
  /call_stack = [^\n]*,add::get1\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b add::get1 ; }
  /call_stack = [^\n]*,add::get2\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b add::get2 ; }
  /call_stack = [^\n]*,add::result\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b add::result ; }
  
  /call_stack = [^\n]*,mul::get1\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b mul::get1 ; }
  /call_stack = [^\n]*,mul::get2\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b mul::get2 ; }
  /call_stack = [^\n]*,mul::prepare_intermediate_result_1\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b mul::prepare_intermediate_result_1 ; }
  /call_stack = [^\n]*,mul::prepare_intermediate_result_2\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b mul::prepare_intermediate_result_2 ; }
  /call_stack = [^\n]*,mul::calculate_intermediate_result\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b mul::calculate_intermediate_result ; }
  /call_stack = [^\n]*,mul::get_intermediate_result\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b mul::get_intermediate_result ; }
  /call_stack = [^\n]*,mul::result\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b mul::result ; }
  
  /call_stack = [^\n]*,div::get1\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b div::get1; }
  /call_stack = [^\n]*,div::get2\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b div::get2; }
  /call_stack = [^\n]*,div::prepare_sub_1\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b div::prepare_sub_1; }
  /call_stack = [^\n]*,div::prepare_sub_2\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b div::prepare_sub_2; }
  /call_stack = [^\n]*,div::execute_sub\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b div::execute_sub; }
  /call_stack = [^\n]*,div::set_remainder\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b div::set_remainder; }
  /call_stack = [^\n]*,div::result_1\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b div::result_1; }
  /call_stack = [^\n]*,div::result_2\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b div::result_2; }
  
  /call_stack = [^\n]*,rng::mul_set_1\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b rng::mul_set_1; }
  /call_stack = [^\n]*,rng::mul_set_2\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b rng::mul_set_2; }
  /call_stack = [^\n]*,rng::add_set_1\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b rng::add_set_1; }
  /call_stack = [^\n]*,rng::add_set_2\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b rng::add_set_2; }
  /call_stack = [^\n]*,rng::div_set_1\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b rng::div_set_1; }
  /call_stack = [^\n]*,rng::div_set_2\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b rng::div_set_2; }
  /call_stack = [^\n]*,rng::execute_mul\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b rng::execute_mul; }
  /call_stack = [^\n]*,rng::execute_add\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b rng::execute_add; }
  /call_stack = [^\n]*,rng::execute_div\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b rng::execute_div; }
  /call_stack = [^\n]*,rng::result\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b rng::result; }
  
  /call_stack = [^\n]*,convert_coordinates::set_digit\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b convert_coordinates::set_digit; }
  /call_stack = [^\n]*,convert_coordinates::set_letter\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b convert_coordinates::set_letter; }
  /call_stack = [^\n]*,convert_coordinates::set_ten\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b convert_coordinates::set_ten; }
  /call_stack = [^\n]*,convert_coordinates::set_add_1\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b convert_coordinates::set_add_1; }
  /call_stack = [^\n]*,convert_coordinates::set_add_2\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b convert_coordinates::set_add_2; }
  /call_stack = [^\n]*,convert_coordinates::execute_mul\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b convert_coordinates::execute_mul; }
  /call_stack = [^\n]*,convert_coordinates::execute_add\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b convert_coordinates::execute_add; }
  /call_stack = [^\n]*,convert_coordinates::get_coordinates\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b convert_coordinates::get_coordinates; }
  /call_stack = [^\n]*,convert_coordinates::result\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b convert_coordinates::result; }
  
  /call_stack = [^\n]*,get_symbol::get_string\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b get_symbol::get_string; }
  /call_stack = [^\n]*,get_symbol::get_number\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b get_symbol::get_number; }
  /call_stack = [^\n]*,get_symbol::result\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b get_symbol::result; }
  
  /call_stack = [^\n]*,set_symbol::get_string\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b set_symbol::get_string; }
  /call_stack = [^\n]*,set_symbol::get_number\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b set_symbol::get_number; }
  /call_stack = [^\n]*,set_symbol::get_symbol\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b set_symbol::get_symbol; }
  /call_stack = [^\n]*,set_symbol::result\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b set_symbol::result; }
  
  /call_stack = [^\n]*,draw::get_field1\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b draw::get_field1; }
  /call_stack = [^\n]*,draw::get_field2\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b draw::get_field2; }
  /call_stack = [^\n]*,draw::get_log\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b draw::get_log; }
  
  /call_stack = [^\n]*,player_move::draw\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b player_move::draw; }
  /call_stack = [^\n]*,player_move::invalid_move\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b player_move::invalid_move; }
  /call_stack = [^\n]*,player_move::already_checked\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b player_move::already_checked; }
  /call_stack = [^\n]*,player_move::log_miss\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b player_move::log_miss; }
  /call_stack = [^\n]*,player_move::log_hit\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b player_move::log_hit; }
  /call_stack = [^\n]*,player_move::log_sink\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b player_move::log_sink; }
  /call_stack = [^\n]*,player_move::set_coordinates\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b player_move::set_coordinates; }
  /call_stack = [^\n]*,player_move::convert_coordinates\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b player_move::convert_coordinates; }
  /call_stack = [^\n]*,player_move::set_suggestion_string\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b player_move::set_suggestion_string; }
  /call_stack = [^\n]*,player_move::set_enemy_string\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b player_move::set_enemy_string; }
  /call_stack = [^\n]*,player_move::set_number\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b player_move::set_number; }
  /call_stack = [^\n]*,player_move::get_enemy_cell\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b player_move::get_enemy_cell; }
  /call_stack = [^\n]*,player_move::put_enemy_cell\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b player_move::put_enemy_cell; }
  /call_stack = [^\n]*,player_move::get_suggestion_cell\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b player_move::get_suggestion_cell; }
  /call_stack = [^\n]*,player_move::put_suggestion_cell\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b player_move::put_suggestion_cell; }
  /call_stack = [^\n]*,player_move::set_missed_string\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b player_move::set_missed_string; }
  /call_stack = [^\n]*,player_move::set_missed_number\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b player_move::set_missed_number; }
  /call_stack = [^\n]*,player_move::set_missed_symbol\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b player_move::set_missed_symbol; }
  /call_stack = [^\n]*,player_move::set_hit_string\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b player_move::set_hit_string; }
  /call_stack = [^\n]*,player_move::set_hit_symbol\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b player_move::set_hit_symbol; }
  /call_stack = [^\n]*,player_move::change_missed_string\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b player_move::change_missed_string; }
  /call_stack = [^\n]*,player_move::change_hit_string\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b player_move::change_hit_string; }
  /call_stack = [^\n]*,player_move::perform_missed\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b player_move::perform_missed; }
  /call_stack = [^\n]*,player_move::perform_hit\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b player_move::perform_hit; }
  /call_stack = [^\n]*,player_move::prepare_analysis_coordinate\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b player_move::prepare_analysis_coordinate; }
  /call_stack = [^\n]*,player_move::prepare_analysis_ships\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b player_move::prepare_analysis_ships; }
  /call_stack = [^\n]*,player_move::prepare_analysis_field\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b player_move::prepare_analysis_field; }
  /call_stack = [^\n]*,player_move::analysis\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b player_move::analysis; }
  /call_stack = [^\n]*,player_move::get_analysis_result\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b player_move::get_analysis_result; }
  /call_stack = [^\n]*,player_move::prepare_mark_coordinates\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b player_move::prepare_mark_coordinates; }
  /call_stack = [^\n]*,player_move::prepare_mark_field\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b player_move::prepare_mark_field; }
  /call_stack = [^\n]*,player_move::prepare_mark_field_2\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b player_move::prepare_mark_field_2; }
  /call_stack = [^\n]*,player_move::get_hit_cell\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b player_move::get_hit_cell; }
  /call_stack = [^\n]*,player_move::get_ship_list\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b player_move::get_ship_list; }
  /call_stack = [^\n]*,player_move::set_ship_cells\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b player_move::set_ship_cells; }
  /call_stack = [^\n]*,player_move::set_suggestions_field\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b player_move::set_suggestions_field; }
  /call_stack = [^\n]*,player_move::mark_diagonal_cross\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b player_move::mark_diagonal_cross; }
  /call_stack = [^\n]*,player_move::set_diagonal_cross\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b player_move::set_diagonal_cross; }
  /call_stack = [^\n]*,player_move::update_before_sink\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b player_move::update_before_sink; }
  /call_stack = [^\n]*,player_move::sink_ship\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b player_move::sink_ship; }
  /call_stack = [^\n]*,player_move::mark_circle\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b player_move::mark_circle; }
  /call_stack = [^\n]*,player_move::check_win\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b player_move::check_win; }
  /call_stack = [^\n]*,player_move::easter_disable\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b player_move::easter_disable; }
  
  /call_stack = [^\n]*,generate_computer_move::random\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b generate_computer_move::random; }
  /call_stack = [^\n]*,generate_computer_move::get_player_field\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b generate_computer_move::get_player_field; }
  /call_stack = [^\n]*,generate_computer_move::calculate_cells_loop\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b generate_computer_move::calculate_cells_loop; }
  /call_stack = [^\n]*,generate_computer_move::inc_healthy_count_loop\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b generate_computer_move::inc_healthy_count_loop; }
  /call_stack = [^\n]*,generate_computer_move::inc_healthy_loop\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b generate_computer_move::inc_healthy_loop; }
  /call_stack = [^\n]*,generate_computer_move::inc_healthy_reverseloop ;\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b generate_computer_move::inc_healthy_reverseloop ;; }
  /call_stack = [^\n]*,generate_computer_move::inc_total_count_loop\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b generate_computer_move::inc_total_count_loop; }
  /call_stack = [^\n]*,generate_computer_move::inc_total_loop\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b generate_computer_move::inc_total_loop; }
  /call_stack = [^\n]*,generate_computer_move::inc_total_reverseloop ;\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b generate_computer_move::inc_total_reverseloop ;; }
  /call_stack = [^\n]*,generate_computer_move::save_2_healthy_cells\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b generate_computer_move::save_2_healthy_cells; }
  /call_stack = [^\n]*,generate_computer_move::save_total_cells_factor\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b generate_computer_move::save_total_cells_factor; }
  /call_stack = [^\n]*,generate_computer_move::prepare_healthy_cells_factor_1\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b generate_computer_move::prepare_healthy_cells_factor_1; }
  /call_stack = [^\n]*,generate_computer_move::prepare_healthy_cells_factor_2\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b generate_computer_move::prepare_healthy_cells_factor_2; }
  /call_stack = [^\n]*,generate_computer_move::perform_mul\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b generate_computer_move::perform_mul; }
  /call_stack = [^\n]*,generate_computer_move::save_healthy_cells_factor\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b generate_computer_move::save_healthy_cells_factor; }
  /call_stack = [^\n]*,generate_computer_move::prepare_add_1\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b generate_computer_move::prepare_add_1; }
  /call_stack = [^\n]*,generate_computer_move::prepare_add_2\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b generate_computer_move::prepare_add_2; }
  /call_stack = [^\n]*,generate_computer_move::perform_add\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b generate_computer_move::perform_add; }
  /call_stack = [^\n]*,generate_computer_move::prepare_random_limitation_1\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b generate_computer_move::prepare_random_limitation_1; }
  /call_stack = [^\n]*,generate_computer_move::prepare_random_limitation_2\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b generate_computer_move::prepare_random_limitation_2; }
  /call_stack = [^\n]*,generate_computer_move::perform_random_limitation\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b generate_computer_move::perform_random_limitation; }
  /call_stack = [^\n]*,generate_computer_move::prepare_set_partition_limit_1\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b generate_computer_move::prepare_set_partition_limit_1; }
  /call_stack = [^\n]*,generate_computer_move::prepare_set_partition_limit_2\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b generate_computer_move::prepare_set_partition_limit_2; }
  /call_stack = [^\n]*,generate_computer_move::calculate_set_partition_limit\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b generate_computer_move::calculate_set_partition_limit; }
  /call_stack = [^\n]*,generate_computer_move::get_limited_random\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b generate_computer_move::get_limited_random; }
  /call_stack = [^\n]*,generate_computer_move::get_set_partition_limit\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b generate_computer_move::get_set_partition_limit; }
  /call_stack = [^\n]*,generate_computer_move::get_luck\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b generate_computer_move::get_luck; }
  /call_stack = [^\n]*,generate_computer_move::prepare_divisor_1\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b generate_computer_move::prepare_divisor_1; }
  /call_stack = [^\n]*,generate_computer_move::prepare_divisor_2\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b generate_computer_move::prepare_divisor_2; }
  /call_stack = [^\n]*,generate_computer_move::build_divisor\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b generate_computer_move::build_divisor; }
  /call_stack = [^\n]*,generate_computer_move::set_hit_dividend\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b generate_computer_move::set_hit_dividend; }
  /call_stack = [^\n]*,generate_computer_move::set_hit_divisor\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b generate_computer_move::set_hit_divisor; }
  /call_stack = [^\n]*,generate_computer_move::perform_hit_div\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b generate_computer_move::perform_hit_div; }
  /call_stack = [^\n]*,generate_computer_move::set_hit_type\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b generate_computer_move::set_hit_type; }
  /call_stack = [^\n]*,generate_computer_move::set_hit_number\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b generate_computer_move::set_hit_number; }
  /call_stack = [^\n]*,generate_computer_move::prepare_miss_sub_1\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b generate_computer_move::prepare_miss_sub_1; }
  /call_stack = [^\n]*,generate_computer_move::prepare_miss_sub_2\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b generate_computer_move::prepare_miss_sub_2; }
  /call_stack = [^\n]*,generate_computer_move::build_dividend\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b generate_computer_move::build_dividend; }
  /call_stack = [^\n]*,generate_computer_move::get_miss_cell_number\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b generate_computer_move::get_miss_cell_number; }
  /call_stack = [^\n]*,generate_computer_move::set_miss_number\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b generate_computer_move::set_miss_number; }
  /call_stack = [^\n]*,generate_computer_move::set_miss_type\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b generate_computer_move::set_miss_type; }
  
  /call_stack = [^\n]*,reverse_convert_coordinates::get_cell_type\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b reverse_convert_coordinates::get_cell_type; }
  /call_stack = [^\n]*,reverse_convert_coordinates::get_cell_number\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b reverse_convert_coordinates::get_cell_number; }
  /call_stack = [^\n]*,reverse_convert_coordinates::get_player_field\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b reverse_convert_coordinates::get_player_field; }
  /call_stack = [^\n]*,reverse_convert_coordinates::prepare_coordinate_div_1\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b reverse_convert_coordinates::prepare_coordinate_div_1; }
  /call_stack = [^\n]*,reverse_convert_coordinates::prepare_coordinate_div_2\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b reverse_convert_coordinates::prepare_coordinate_div_2; }
  /call_stack = [^\n]*,reverse_convert_coordinates::perform_coordinate_div\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b reverse_convert_coordinates::perform_coordinate_div; }
  /call_stack = [^\n]*,reverse_convert_coordinates::save_result_number\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b reverse_convert_coordinates::save_result_number; }
  /call_stack = [^\n]*,reverse_convert_coordinates::save_result_string\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b reverse_convert_coordinates::save_result_string; }
  /call_stack = [^\n]*,reverse_convert_coordinates::get_y_coordinate\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b reverse_convert_coordinates::get_y_coordinate; }
  /call_stack = [^\n]*,reverse_convert_coordinates::get_x_coordinate\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b reverse_convert_coordinates::get_x_coordinate; }
  
  /call_stack = [^\n]*,computer_move::draw\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b computer_move::draw; }
  /call_stack = [^\n]*,computer_move::get_ct\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b computer_move::get_ct; }
  /call_stack = [^\n]*,computer_move::miss_get_log\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b computer_move::miss_get_log; }
  /call_stack = [^\n]*,computer_move::miss_set_log\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b computer_move::miss_set_log; }
  /call_stack = [^\n]*,computer_move::hit_get_log\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b computer_move::hit_get_log; }
  /call_stack = [^\n]*,computer_move::hit_set_log\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b computer_move::hit_set_log; }
  /call_stack = [^\n]*,computer_move::generate_move\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b computer_move::generate_move; }
  /call_stack = [^\n]*,computer_move::calculate_coordinates\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b computer_move::calculate_coordinates; }
  /call_stack = [^\n]*,computer_move::get_hit_coordinates\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b computer_move::get_hit_coordinates; }
  /call_stack = [^\n]*,computer_move::get_miss_coordinates\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b computer_move::get_miss_coordinates; }
  /call_stack = [^\n]*,computer_move::set_missed_symbol\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b computer_move::set_missed_symbol; }
  /call_stack = [^\n]*,computer_move::set_missed_string\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b computer_move::set_missed_string; }
  /call_stack = [^\n]*,computer_move::set_missed_number\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b computer_move::set_missed_number; }
  /call_stack = [^\n]*,computer_move::set_hit_symbol\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b computer_move::set_hit_symbol; }
  /call_stack = [^\n]*,computer_move::set_hit_number\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b computer_move::set_hit_number; }
  /call_stack = [^\n]*,computer_move::set_hit_string\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b computer_move::set_hit_string; }
  /call_stack = [^\n]*,computer_move::change_missed_string\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b computer_move::change_missed_string; }
  /call_stack = [^\n]*,computer_move::change_hit_string\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b computer_move::change_hit_string; }
  /call_stack = [^\n]*,computer_move::perform_missed\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b computer_move::perform_missed; }
  /call_stack = [^\n]*,computer_move::perform_hit\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b computer_move::perform_hit; }
  /call_stack = [^\n]*,computer_move::prepare_mark_coordinates\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b computer_move::prepare_mark_coordinates; }
  /call_stack = [^\n]*,computer_move::prepare_mark_field\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b computer_move::prepare_mark_field; }
  /call_stack = [^\n]*,computer_move::mark_diagonal_cross\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b computer_move::mark_diagonal_cross; }
  /call_stack = [^\n]*,computer_move::set_diagonal_cross\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b computer_move::set_diagonal_cross; }
  /call_stack = [^\n]*,computer_move::prepare_analysis_coordinate\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b computer_move::prepare_analysis_coordinate; }
  /call_stack = [^\n]*,computer_move::prepare_analysis_ships\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b computer_move::prepare_analysis_ships; }
  /call_stack = [^\n]*,computer_move::prepare_analysis_field\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b computer_move::prepare_analysis_field; }
  /call_stack = [^\n]*,computer_move::analysis\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b computer_move::analysis; }
  /call_stack = [^\n]*,computer_move::get_analysis_result\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b computer_move::get_analysis_result; }
  /call_stack = [^\n]*,computer_move::check_lose\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b computer_move::check_lose; }
  /call_stack = [^\n]*,computer_move::update_before_sink\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b computer_move::update_before_sink; }
  /call_stack = [^\n]*,computer_move::sink_ship\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b computer_move::sink_ship; }
  /call_stack = [^\n]*,computer_move::get_hit_cell\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b computer_move::get_hit_cell; }
  /call_stack = [^\n]*,computer_move::get_ship_list\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b computer_move::get_ship_list; }
  /call_stack = [^\n]*,computer_move::prepare_mark_field_2\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b computer_move::prepare_mark_field_2; }
  /call_stack = [^\n]*,computer_move::set_ship_cells\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b computer_move::set_ship_cells; }
  /call_stack = [^\n]*,computer_move::mark_circle\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b computer_move::mark_circle; }
  /call_stack = [^\n]*,computer_move::update_after_sink\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b computer_move::update_after_sink; }
  
  /call_stack = [^\n]*,analyze_ship_state::init\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b analyze_ship_state::init; }
  /call_stack = [^\n]*,analyze_ship_state::get_ship_cell\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b analyze_ship_state::get_ship_cell ; }
  /call_stack = [^\n]*,analyze_ship_state::get_all_ships\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b analyze_ship_state::get_all_ships; }
  /call_stack = [^\n]*,analyze_ship_state::set_enemy_string\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b analyze_ship_state::set_enemy_string; }
  /call_stack = [^\n]*,analyze_ship_state::set_enemy_cell\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b analyze_ship_state::set_enemy_cell; }
  /call_stack = [^\n]*,analyze_ship_state::calculate_enemy_cell\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b analyze_ship_state::calculate_enemy_cell; }
  /call_stack = [^\n]*,analyze_ship_state::get_enemy_cell\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b analyze_ship_state::get_enemy_cell; }
  /call_stack = [^\n]*,analyze_ship_state::sunk\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b analyze_ship_state::sunk; }
  
  /call_stack = [^\n]*,sink_computer_ship::get_ship_cell\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b sink_computer_ship::get_ship_cell; }
  /call_stack = [^\n]*,sink_computer_ship::get_all_ships\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b sink_computer_ship::get_all_ships; }
  /call_stack = [^\n]*,sink_computer_ship::set_sink_symbol\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b sink_computer_ship::set_sink_symbol; }
  /call_stack = [^\n]*,sink_computer_ship::sink_loop\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b sink_computer_ship::sink_loop; }
  /call_stack = [^\n]*,sink_computer_ship::set_cell_number\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b sink_computer_ship::set_cell_number; }
  /call_stack = [^\n]*,sink_computer_ship::set_enemy_string\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b sink_computer_ship::set_enemy_string; }
  /call_stack = [^\n]*,sink_computer_ship::change_enemy_field\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b sink_computer_ship::change_enemy_field; }
  /call_stack = [^\n]*,sink_computer_ship::save_enemy_field\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b sink_computer_ship::save_enemy_field; }
  /call_stack = [^\n]*,sink_computer_ship::set_suggestions_string\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b sink_computer_ship::set_suggestions_string; }
  /call_stack = [^\n]*,sink_computer_ship::change_suggestions_field\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b sink_computer_ship::change_suggestions_field; }
  /call_stack = [^\n]*,sink_computer_ship::save_suggestions_field\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b sink_computer_ship::save_suggestions_field; }
  
  /call_stack = [^\n]*,sink_player_ship::get_ship_cell\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b sink_player_ship::get_ship_cell; }
  /call_stack = [^\n]*,sink_player_ship::get_all_ships\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b sink_player_ship::get_all_ships; }
  /call_stack = [^\n]*,sink_player_ship::set_sink_symbol\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b sink_player_ship::set_sink_symbol; }
  /call_stack = [^\n]*,sink_player_ship::sink_loop\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b sink_player_ship::sink_loop; }
  /call_stack = [^\n]*,sink_player_ship::set_cell_number\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b sink_player_ship::set_cell_number; }
  /call_stack = [^\n]*,sink_player_ship::set_enemy_string\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b sink_player_ship::set_enemy_string; }
  /call_stack = [^\n]*,sink_player_ship::change_enemy_field\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b sink_player_ship::change_enemy_field; }
  /call_stack = [^\n]*,sink_player_ship::save_enemy_field\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b sink_player_ship::save_enemy_field; }
  
  /call_stack = [^\n]*,mark_diagonal_cross::set_water_symbol\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b mark_diagonal_cross::set_water_symbol; }
  /call_stack = [^\n]*,mark_diagonal_cross::div_set_1\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b mark_diagonal_cross::div_set_1; }
  /call_stack = [^\n]*,mark_diagonal_cross::div_set_2\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b mark_diagonal_cross::div_set_2; }
  /call_stack = [^\n]*,mark_diagonal_cross::execute_div\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b mark_diagonal_cross::execute_div; }
  /call_stack = [^\n]*,mark_diagonal_cross::get_y_coordinate\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b mark_diagonal_cross::get_y_coordinate; }
  /call_stack = [^\n]*,mark_diagonal_cross::get_x_coordinate\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b mark_diagonal_cross::get_x_coordinate; }
  /call_stack = [^\n]*,mark_diagonal_cross::set_add_1\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b mark_diagonal_cross::set_add_1; }
  /call_stack = [^\n]*,mark_diagonal_cross::set_add_2\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b mark_diagonal_cross::set_add_2; }
  /call_stack = [^\n]*,mark_diagonal_cross::calculate_cross_cell\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b mark_diagonal_cross::calculate_cross_cell; }
  /call_stack = [^\n]*,mark_diagonal_cross::set_mark_cell\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b mark_diagonal_cross::set_mark_cell; }
  /call_stack = [^\n]*,mark_diagonal_cross::set_suggestions_string\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b mark_diagonal_cross::set_suggestions_string; }
  /call_stack = [^\n]*,mark_diagonal_cross::perform_field_change\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b mark_diagonal_cross::perform_field_change; }
  /call_stack = [^\n]*,mark_diagonal_cross::change_suggestions_field\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b mark_diagonal_cross::change_suggestions_field; }
  /call_stack = [^\n]*,mark_diagonal_cross::cross_cell_handled\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b mark_diagonal_cross::cross_cell_handled; }
  
  /call_stack = [^\n]*,mark_circle::get_ship_cells\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b mark_circle::get_ship_cells; }
  /call_stack = [^\n]*,mark_circle::set_ship_cell\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b mark_circle::set_ship_cell; }
  /call_stack = [^\n]*,mark_circle::mark_common_cross\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b mark_circle::mark_common_cross; }
  
  /call_stack = [^\n]*,mark_common_cross::set_water_symbol\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b mark_common_cross::set_water_symbol; }
  /call_stack = [^\n]*,mark_common_cross::div_set_1\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b mark_common_cross::div_set_1; }
  /call_stack = [^\n]*,mark_common_cross::div_set_2\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b mark_common_cross::div_set_2; }
  /call_stack = [^\n]*,mark_common_cross::execute_div\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b mark_common_cross::execute_div; }
  /call_stack = [^\n]*,mark_common_cross::get_y_coordinate\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b mark_common_cross::get_y_coordinate; }
  /call_stack = [^\n]*,mark_common_cross::get_x_coordinate\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b mark_common_cross::get_x_coordinate; }
  /call_stack = [^\n]*,mark_common_cross::set_add_1\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b mark_common_cross::set_add_1; }
  /call_stack = [^\n]*,mark_common_cross::set_add_2\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b mark_common_cross::set_add_2; }
  /call_stack = [^\n]*,mark_common_cross::calculate_cross_cell\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b mark_common_cross::calculate_cross_cell; }
  /call_stack = [^\n]*,mark_common_cross::set_cell_to_check\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b mark_common_cross::set_cell_to_check; }
  /call_stack = [^\n]*,mark_common_cross::get_ship_cells\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b mark_common_cross::get_ship_cells; }
  /call_stack = [^\n]*,mark_common_cross::set_mark_cell\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b mark_common_cross::set_mark_cell; }
  /call_stack = [^\n]*,mark_common_cross::set_suggestions_string\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b mark_common_cross::set_suggestions_string; }
  /call_stack = [^\n]*,mark_common_cross::perform_field_change\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b mark_common_cross::perform_field_change; }
  /call_stack = [^\n]*,mark_common_cross::change_suggestions_field\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b mark_common_cross::change_suggestions_field; }
  /call_stack = [^\n]*,mark_common_cross::cross_cell_handled\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b mark_common_cross::cross_cell_handled; }
  
  /call_stack = [^\n]*,check_win::get_enemy_field\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b check_win::get_enemy_field; }
  /call_stack = [^\n]*,check_win::draw\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b check_win::draw; }
  /call_stack = [^\n]*,check_win::check_easter\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b check_win::check_easter; }
  
  /call_stack = [^\n]*,check_lose::get_player_field\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b check_lose::get_player_field; }
  /call_stack = [^\n]*,check_lose::draw\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b check_lose::draw; }

  /call_stack = [^\n]*,set_player_ships::create_ships\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b set_player_ships::create_ships; }
  /call_stack = [^\n]*,set_player_ships::place_loop\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b set_player_ships::place_loop; }
  /call_stack = [^\n]*,set_player_ships::draw\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b set_player_ships::draw; }
  /call_stack = [^\n]*,set_player_ships::get_ships_to_place\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b set_player_ships::get_ships_to_place; }
  /call_stack = [^\n]*,set_player_ships::remove_ship\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b set_player_ships::remove_ship; }
  /call_stack = [^\n]*,set_player_ships::prepare_ship_to_return\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b set_player_ships::prepare_ship_to_return; }
  /call_stack = [^\n]*,set_player_ships::return_ship\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b set_player_ships::return_ship; }
  /call_stack = [^\n]*,set_player_ships::log_invalid_place\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b set_player_ships::log_invalid_place; }
  /call_stack = [^\n]*,set_player_ships::log_valid_place\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b set_player_ships::log_valid_place; }
  /call_stack = [^\n]*,set_player_ships::set_orientation\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b set_player_ships::set_orientation; }
  /call_stack = [^\n]*,set_player_ships::set_length\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b set_player_ships::set_length; }
  /call_stack = [^\n]*,set_player_ships::set_coordinates\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b set_player_ships::set_coordinates; }
  /call_stack = [^\n]*,set_player_ships::set_field\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b set_player_ships::set_field; }
  /call_stack = [^\n]*,set_player_ships::place_ship\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b set_player_ships::place_ship; }
  /call_stack = [^\n]*,set_player_ships::get_placing_result\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b set_player_ships::get_placing_result; }
  /call_stack = [^\n]*,set_player_ships::handle_placing_error\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b set_player_ships::handle_placing_error; }
  /call_stack = [^\n]*,set_player_ships::update_field\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b set_player_ships::update_field; }
  /call_stack = [^\n]*,set_player_ships::get_player_ships\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b set_player_ships::get_player_ships; }
  /call_stack = [^\n]*,set_player_ships::update_player_ships\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b set_player_ships::update_player_ships; }
  /call_stack = [^\n]*,set_player_ships::prepare_final_update\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b set_player_ships::prepare_final_update; }
  /call_stack = [^\n]*,set_player_ships::final_update\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b set_player_ships::final_update; }
  /call_stack = [^\n]*,set_player_ships::log_game_start\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b set_player_ships::log_game_start; }
  /call_stack = [^\n]*,set_player_ships::prepare_coordinate_conversion\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b set_player_ships::prepare_coordinate_conversion; }
  /call_stack = [^\n]*,set_player_ships::convert_coordinates\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b set_player_ships::convert_coordinates; }
  /call_stack = [^\n]*,set_player_ships::set_start_coordinate\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b set_player_ships::set_start_coordinate; }

  /call_stack = [^\n]*,place_ship::get_length\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b place_ship::get_length; }
  /call_stack = [^\n]*,place_ship::get_orientation\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b place_ship::get_orientation; }
  /call_stack = [^\n]*,place_ship::get_coordinates\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b place_ship::get_coordinates; }
  /call_stack = [^\n]*,place_ship::set_field_string\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b place_ship::set_field_string; }
  /call_stack = [^\n]*,place_ship::set_coordinate_to_get\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b place_ship::set_coordinate_to_get; }
  /call_stack = [^\n]*,place_ship::get_potential_cell\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b place_ship::get_potential_cell; }
  /call_stack = [^\n]*,place_ship::put_potential_cell\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b place_ship::put_potential_cell; }
  /call_stack = [^\n]*,place_ship::div_set_1\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b place_ship::div_set_1; }
  /call_stack = [^\n]*,place_ship::div_set_2\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b place_ship::div_set_2; }
  /call_stack = [^\n]*,place_ship::execute_div\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b place_ship::execute_div; }
  /call_stack = [^\n]*,place_ship::get_mod_result\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b place_ship::get_mod_result; }
  /call_stack = [^\n]*,place_ship::get_div_result\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b place_ship::get_div_result; }
  /call_stack = [^\n]*,place_ship::prepare_coordinate_change_1\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b place_ship::prepare_coordinate_change_1; }
  /call_stack = [^\n]*,place_ship::prepare_coordinate_change_2\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b place_ship::prepare_coordinate_change_2; }
  /call_stack = [^\n]*,place_ship::calculate_next_coordinate\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b place_ship::calculate_next_coordinate; }
  /call_stack = [^\n]*,place_ship::get_next_coordinate\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b place_ship::get_next_coordinate; }
  /call_stack = [^\n]*,place_ship::set_error\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b place_ship::set_error; }
  /call_stack = [^\n]*,place_ship::init_result\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b place_ship::init_result; }
  /call_stack = [^\n]*,place_ship::update_ship_placement\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b place_ship::update_ship_placement; }
  /call_stack = [^\n]*,place_ship::set_ship_symbol\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b place_ship::set_ship_symbol; }
  /call_stack = [^\n]*,place_ship::set_cell_number\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b place_ship::set_cell_number; }
  /call_stack = [^\n]*,place_ship::set_field\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b place_ship::set_field; }
  /call_stack = [^\n]*,place_ship::mark_ship\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b place_ship::mark_ship; }
  /call_stack = [^\n]*,place_ship::update_field\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b place_ship::update_field; }
  /call_stack = [^\n]*,place_ship::prepare_diagonal_mark_coordinates\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b place_ship::prepare_diagonal_mark_coordinates; }
  /call_stack = [^\n]*,place_ship::prepare_diagonal_mark_field\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b place_ship::prepare_diagonal_mark_field; }
  /call_stack = [^\n]*,place_ship::mark_diagonal_cross\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b place_ship::mark_diagonal_cross; }
  /call_stack = [^\n]*,place_ship::set_diagonal_cross\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b place_ship::set_diagonal_cross; }
  /call_stack = [^\n]*,place_ship::set_ship_to_circle\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b place_ship::set_ship_to_circle; }
  /call_stack = [^\n]*,place_ship::mark_circle\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b place_ship::mark_circle; }
  /call_stack = [^\n]*,place_ship::set_circle\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b place_ship::set_circle; }
  
  /call_stack = [^\n]*,select_difficulty::set_luck\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b select_difficulty::set_luck; }
  
  /call_stack = [^\n]*,main::select_difficulty\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b main::select_difficulty; }
  /call_stack = [^\n]*,main::set_player_ships\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b main::set_player_ships; }
  /call_stack = [^\n]*,main::log_ships_placement\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b main::log_ships_placement; }
  /call_stack = [^\n]*,main::draw\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b main::draw; }
  /call_stack = [^\n]*,main::rng_seed\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b main::rng_seed; }
  /call_stack = [^\n]*,main::set_computer_ships\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b main::set_computer_ships; }

  /call_stack = [^\n]*,rng_seed::get_rng_seed_parts_1\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b rng_seed::get_rng_seed_parts_1; }
  /call_stack = [^\n]*,rng_seed::get_rng_seed_parts_2\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b rng_seed::get_rng_seed_parts_2; }
  /call_stack = [^\n]*,rng_seed::get_rng_seed_parts_3\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b rng_seed::get_rng_seed_parts_3; }
  /call_stack = [^\n]*,rng_seed::set_dividend\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b rng_seed::set_dividend; }
  /call_stack = [^\n]*,rng_seed::set_divisor\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b rng_seed::set_divisor; }
  /call_stack = [^\n]*,rng_seed::perform_division\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b rng_seed::perform_division; }
  /call_stack = [^\n]*,rng_seed::get_raw_seed\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b rng_seed::get_raw_seed; }
  /call_stack = [^\n]*,rng_seed::set_seed\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b rng_seed::set_seed; }

  /call_stack = [^\n]*,set_computer_ships::create_ships\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b set_computer_ships::create_ships; }
  /call_stack = [^\n]*,set_computer_ships::place_loop\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b set_computer_ships::place_loop; }
  /call_stack = [^\n]*,set_computer_ships::draw\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b set_computer_ships::draw; }
  /call_stack = [^\n]*,set_computer_ships::get_ships_to_place\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b set_computer_ships::get_ships_to_place; }
  /call_stack = [^\n]*,set_computer_ships::remove_ship\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b set_computer_ships::remove_ship; }
  /call_stack = [^\n]*,set_computer_ships::got_ship\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b set_computer_ships::got_ship; }
  /call_stack = [^\n]*,set_computer_ships::gen_random\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b set_computer_ships::gen_random; }
  /call_stack = [^\n]*,set_computer_ships::get_random\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b set_computer_ships::get_random; }
  /call_stack = [^\n]*,set_computer_ships::prepare_coordinate_conversion_1\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b set_computer_ships::prepare_coordinate_conversion_1; }
  /call_stack = [^\n]*,set_computer_ships::prepare_coordinate_conversion_2\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b set_computer_ships::prepare_coordinate_conversion_2; }
  /call_stack = [^\n]*,set_computer_ships::convert_coordinates\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b set_computer_ships::convert_coordinates; }
  /call_stack = [^\n]*,set_computer_ships::get_coordinates\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b set_computer_ships::get_coordinates; }
  /call_stack = [^\n]*,set_computer_ships::invalid_placement\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b set_computer_ships::invalid_placement; }
  /call_stack = [^\n]*,set_computer_ships::prepare_ship_to_return\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b set_computer_ships::prepare_ship_to_return; }
  /call_stack = [^\n]*,set_computer_ships::return_ship\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b set_computer_ships::return_ship; }
  /call_stack = [^\n]*,set_computer_ships::valid_placement\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b set_computer_ships::valid_placement; }
  /call_stack = [^\n]*,set_computer_ships::get_current_log\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b set_computer_ships::get_current_log; }
  /call_stack = [^\n]*,set_computer_ships::log_valid_place\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b set_computer_ships::log_valid_place; }
  /call_stack = [^\n]*,set_computer_ships::convert_coordinates\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b set_computer_ships::convert_coordinates; }
  /call_stack = [^\n]*,set_computer_ships::set_orientation\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b set_computer_ships::set_orientation; }
  /call_stack = [^\n]*,set_computer_ships::set_coordinates\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b set_computer_ships::set_coordinates; }
  /call_stack = [^\n]*,set_computer_ships::set_length\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b set_computer_ships::set_length; }
  /call_stack = [^\n]*,set_computer_ships::set_field\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b set_computer_ships::set_field; }
  /call_stack = [^\n]*,set_computer_ships::place_ship\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b set_computer_ships::place_ship; }
  /call_stack = [^\n]*,set_computer_ships::get_placing_result\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b set_computer_ships::get_placing_result; }
  /call_stack = [^\n]*,set_computer_ships::handle_placing_error\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b set_computer_ships::handle_placing_error; }
  /call_stack = [^\n]*,set_computer_ships::update_field\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b set_computer_ships::update_field; }
  /call_stack = [^\n]*,set_computer_ships::get_computer_ships\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b set_computer_ships::get_computer_ships; }
  /call_stack = [^\n]*,set_computer_ships::update_computer_ships\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b set_computer_ships::update_computer_ships; }
  /call_stack = [^\n]*,set_computer_ships::end_placing\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b set_computer_ships::end_placing; }
  /call_stack = [^\n]*,set_computer_ships::prepare_final_update\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b set_computer_ships::prepare_final_update; }
  /call_stack = [^\n]*,set_computer_ships::final_update\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b set_computer_ships::final_update; }
  /call_stack = [^\n]*,set_computer_ships::log_game_start\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b set_computer_ships::log_game_start; }
  
  /call_stack = [^\n]*,easter::get_shots\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b easter::get_shots; }
  /call_stack = [^\n]*,easter::log_set\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b easter::log_set; }
  /call_stack = [^\n]*,easter::get_field\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b easter::get_field; }
  /call_stack = [^\n]*,easter::set_field\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b easter::set_field; }
  /call_stack = [^\n]*,easter::set_shots\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b easter::set_shots; }
}

