.text
.globl main

#########################################################################################################################################
																																		#
main:

	li 		$v0, 4					# opcode for print_string
	la 		$a0, prompt 			# loads prompt into $a0
	syscall

	li 		$v0, 8 					# opcode for read_string
	la 		$a0, infix 				# address for input
	syscall
	add 	$t0, $a0, $0 			# move infix address to $t0

	lb 		$s0, open 				# loads byte '(' into $s0
	lb 		$s1, close 				# loads byte ')' into $s1
	lb 		$s3, plus				# loads byte '+' into $s3
	lb 		$s4, minus 				# loads byte '-' into $s4
	la 		$t6, postfix 			# loads address for postfix expression
	add 	$t6, $t6, 20 			# increments address of postfix by 20
	addi 	$sp, $sp, -20 			# allocate space for stack
	add 	$t4, $0, $0 			# counter for stack counter

	li 		$t1, 0 					# set counter to 0
	jal 	length 					# jump to length and save return address

	j 		convert 				# jump to convert

###########################################################################################

length:
	lb 	 	$t2, 0($t0) 			# get character from infix expression
	add 	$t1, $t1, 1 			# increment counter
	add 	$t0, $t0, 1 			# increment position of infix expression
	beqz 	$t2, continue 			# if character is zero, go to continue
	j 		length 					# else loop

###########################################################################################

continue:
	sub 	$t0, $t0, $t1 			# reset position in infix expression
	j 		$ra 					# jump to return address

###########################################################################################

convert:
	lb 		$t3, 0($t0)	 			# loads first character of infix expression into $t1
	add 	$t1, $t1, -1 			# decrement counter

	beqz 	$t1, print
	beq 	$t3, $s1, pop 			# If byte is ')' pop
	beq 	$t3, $s0, push 			# If byte is '(' push
	beq 	$t3, $s3, push 			# If byte is '+' push
	beq 	$t3, $s4, push 			# If byte is '-' push

	sb 		$t3, 0($t6) 			# Byte is operand, and is appended to final postfix expression
	add 	$t4, $t4, 1				# increments stack counter
	addi 	$t6, $t6, 1 			# increments postfix expression position
	addi 	$t0, $t0, 1 			# increments infix address position

	j 		convert
	
###########################################################################################

push:

	sb 		$t3, 0($sp) 			# stores byte in the next stack position
	add 	$sp, $sp, 1 			# increments position of stack
	addi 	$t0, $t0, 1 			# increments infix address position
	j 		convert

###########################################################################################

pop:
	addi 	$sp, $sp, -1 		# decrement stack position
	lb 		$t5, 0($sp) 		# pop top of stack
	sb 		$t5, 0($t6) 		# append popped value to postfix expression
	add 	$t4, $t4, 1			# increments stack counter
	addi 	$t6, $t6, 1 		# increment postfix position
	lb 		$t5, -1($sp) 		# peek at top of stack
	beq 	$t5, $s0, end_pop 	# if top of stack = '(', stop popping
	j 		pop 				# else loop

###########################################################################################

end_pop:
	sub 	$sp, $sp, 1 			# decrement stack position
	sb 		$0, 0($sp) 				# clear stack pointer position
	add 	$t0, $t0, 1 			# increment counter for position reset
	bne 	$t0, $0, convert 		# if $t0 is not equal to zero loop back to convert
	j 		print					# else jump to end

###########################################################################################

length_post:

	lb 	 	$t0, 0($t6)			# load first value of postfix into $t0
	beqz 	$t0, finish 		# if value is 0, go to loop
	add 	$t2, $t2, 1 		# increment length counter
	add 	$t6, $t6, 1 		# increment postfix address position
	j 		length_post 			# else, loop back
																																		#
#########################################################################################################################################
																																		#
create_tree:

 	add 	$t1, $s6, $0 		# temporary variable for length
 	addi 	$sp, $sp, -40 		# allocate space for stack
 	sub 	$t6, $t6, $t0 		# reset addr position for postfix string
 	add 	$s0, $0, $0 		# reset $s0 to use as the address for the root of the tree
	add 	$s1, $0, $0 		# reset $s1 
	add 	$t5, $0, $0 		# reset $t5
	add 	$t4, $0, $0 		# reset $t4
	add 	$t0, $0, $0 		# reset $t0 to use as an address offset counter

###########################################################################################

iterate:
 	
 	beqz 	$t1, preorder	
 	lb 		$t7, 0($t6) 		# load current postfix character
 	add 	$t0, $t0, 1 		# increment counter for offset
 	add 	$t1, $t1, -1 		# decrement counter
 	add 	$t6, $t6, 1 		# increment postfix position

 	beq 	$t7, $s3, parent 	# if '+', jump to parent
 	beq 	$t7, $s4, parent 	# if '-', jump to parent

 	j leaf 						# else, jump to leaf

###########################################################################################

 parent:

 	li 		$v0, 9 				# opcode for memory allocation
 	la 		$a0, 32 			# creates space for data about node
 	syscall

 	move 	$s0, $v0 			# stores address of root in $s0
 	sub 	$sp, $sp, 4
 	lw 		$t8, 0($sp)			# pop stack
 	sub 	$sp, $sp, 4
 	lw 		$t9, 0($sp) 		# pop stack

 	sw 		$s0, 0($t8) 		# set root node of new leaf
 	sw 		$s0, 0($t9)			# set root node of new leaf
 	sw 		$t8, 8($s0) 		# store address of right leaf in root node
 	sw 		$t9, 4($s0)			# store address of left leaf in root node
 	sb 		$t7, 12($s0) 		# store char value in root node

 	sw 		$s0, 0($sp) 		# push new root node onto stack
 	add 	$sp, $sp, 4 		# increment stack
 	j 		iterate

###########################################################################################

 leaf:

 	li 		$v0, 9 				# opcode for memory allocation
 	la 		$a0, 32 			# creates space for data about node
 	syscall

 	move 	$s0, $v0 			# move addr of new leaf to $s0

 	sw 		$t7, 12($s0) 		# store char value into the node
 	sw		$s0, 0($sp) 		# stores byte in the next stack position
	add 	$sp, $sp, 4 		# increments position of stack
	j 		iterate 			# loop back
 																																		#
#########################################################################################################################################
																																		#
preorder:

	add 	$s1, $s0, $0 			# save expression tree root addr
	la 		$s2, preorderstring 	# load addr for preorder string
	add 	$t4, $0, $0 			# set $t4 to 0

###########################################################################################

new_node:

	lb 		$t7, 12($s1) 			# load char value of current node 
	add 	$t4, $t4, 1 			# append value to preorder
	sb 		$t7, 0($s2) 			# append char value to preorder string
	add 	$s2, $s2, 1 			# increment preorder string position
	j traverse_left 					# jump to traverse_left

###########################################################################################
	
traverse_left:
	
	lw 		$t7, 4($s1) 			# load addr of left node into $t7
	beqz 	$t7, go_back 			# if left node is null, branch to go_back
	add 	$s1, $t7, $0 			# else, set left node as the current node
	j 		new_node 				# jumo to new_node

###########################################################################################

go_back:
	
	lw 		$t7, 0($s1) 			# load addr of parent node into $t7
	beq 	$t7, $s0, flag 			# if parent is the root of the expression tree, branch to flag
resume:
	lw 		$t8, 8($t7) 			# load addr of right node into $t8
	beq  	$s1, $t8, double_back 	# if $t8 is the right node of the current node, branch to double_back
	add 	$s1, $t7, $0 			# else, set parent as the current node
	j 		traverse_right 			# jump to traverse_right

###########################################################################################

flag:
	
	beq 	$s5, 1, preorder_print 		# if flag is on, branch to preorder_print
	add 	$s5, $s5, 1 				# else, turn flag on
	j 		resume 						# jump to resume

###########################################################################################

traverse_right:
		
	lw 		$t7, 8($s1) 				# load addr of right node into $t7
	add 	$s1, $t7, $0 				# set right node as the current node
	j 		new_node 	 				# jump to new_node

###########################################################################################

double_back:
	
	lw 		$t8, 0($t7) 				# load addr of parent into $t8
	beq 	$t8, $s0, increment_flag 	# if parent is the root of the expression tree, branch to increment_flag
switch:
	add 	$s1, $t8, $0 				# set parent as the current node
	j 		traverse_right 				# jump to traverse_right

###########################################################################################

increment_flag:
	
	beq 	$s5, 1, preorder_print 		# if flag is on, branch to preorder_print
	add 	$s5, $s5, 1 				# else, turn flag on
	j  		switch 						# jump to switch

###########################################################################################

finish:

	j 		$ra 				# jump to return address																	
																																		#
#########################################################################################################################################
																																		#
print:	
	
	sub 	$t6, $t6, $t4		# reset position of postfix address to start
	jal 	length_post 			# jump with return addr to length_post
	sub 	$t6, $t6, $t2 		# reset postfix address to start
	add 	$t2, $t2, -1 		# +1 for the counter to loop completely
	add 	$s6, $t2, $0 		# saves length for later use

	li $v0, 4 					# opcode for print_string
	la $a0, prompt2 			# load addr for prompt2
	syscall
	
loop:
	beqz 	$t2, create_tree 	# if counter = 0, go to finish
	lb 		$t7, 0($t6) 		# loads character from postfix
	li 		$v0, 11 			# opcode for print_char
	move 	$a0, $t7 			# moves char to be printed into $a0
	syscall
	add 	$t2, $t2, -1 		# decrements counter
	add 	$t0, $t0, 1 		# increment counter
	add 	$t6, $t6, 1 		# increments position in postfix expression
	j 		loop 				# loop
												#
#########################################################################################################################################
																																		#
preorder_print:
	
	sub 	$s2, $s2, $t4 		# reset position of preorder string

	li 		$v0, 4 				# opcode for print_string
	la 		$a0, newline		# load addr for newline
	syscall

	la 		$a0, prompt3 		# load addr for prompt3
	syscall

 print_loop:
	beqz 	$t0, evaluate 		# if counter = 0, branch to evaluate
	add 	$t0, $t0, -1 		# decrement counter
	lb 		$t7, 0($s2) 		# load char from preorder string
	add 	$s2, $s2, 1 		# increment offset counter
	li 		$v0, 11 			# opcode for print_char
	move 	$a0, $t7 			# move value into buffer
	syscall
	j 		print_loop 			# jump to print_loop
																																		#
#########################################################################################################################################
																																		#
evaluate:

	add 	$s1, $s0, $0 			# saves address of expression tree
	add 	$t5, $0, $0 			# sets $t5 to 0
	add 	$s7, $0, $0 			# sets $s7 to 0

eval_loop:

	lb 		$t7, 12($s1) 			# loads root of the tree
	lw 		$t8, 4($s1) 			# load left leaf addr
	lw 		$t9, 8($s1) 			# loads right leaf addr
 	lb 		$t0, 12($t8) 			# loads left leaf char
 	lb 		$t1, 12($t9) 			# loads right leaf char

 	bnez 	$t5, check_flag 			# check the flag
 	
 	beq 	$t0, $s3, eval_left 		# if left leaf is '+' branch to eval_left
 	beq 	$t0, $s4, eval_left 		# if left leaf is '-' branch to eval_left

 	beq 	$t1, $s3, eval_right 	# if right leaf is '+' branch to eval_right
 	beq 	$t1, $s4, eval_right 	# if right leaf is '-' branch to eval_right

 	beq 	$t7, $s3, addition 		# if root char is '+' branch to addition
 	beq 	$t7, $s4, subtract 		# if root char is '-' branch to subtract


###########################################################################################

 check_flag:

 	beq 	$s1, $s0, final_traversal 		# if current addr is equal to root addr, branch to final_traversal
 	beq 	$t7, $s3, addition 				# if root char is '+' branch to addition
 	beq 	$t7, $s4, subtract 				# if root char is '-' branch to subtract

###########################################################################################

 addition:
 	sub 	$t0, $t0, 48 					# subtract 48 for printing purposes
 	sub 	$t1, $t1, 48 				 	# subtract 48 for printing purposes
  	bnez 	$t5, add_swap 					# if flag has been changed, branch to add_swap
 resume_addition: 
 	add 	$t2, $t0, $t1 					# add two leaves and store in $t2
 	sb 		$t2, 0($sp) 					# store sum in stack
 	add 	$sp, $sp, 4 					# increment the stack position
 	add 	$t5, $t5, 1 					# switch flag on
 	j 		return 							# jump to return

###########################################################################################

 add_swap:

 	add 	$sp, $sp, -4 					# decrement stack position
 	lb 		$t0, 0($sp) 					# load current stack value
 	add 	$t5, $t5, -1 					# turn off flag
 	j 		resume_addition 				# jump to reusme_addition

###########################################################################################

 subtract:

 	sub 	$t0, $t0, 48 					# subtract 48 for printing purposes
 	sub 	$t1, $t1, 48 					# subtract 48 for printing purposes
 	bnez 	$t5, sub_swap 					# if flag has been changed, branch to sub_swap
 resume_subtract:
 	sub 	$t2, $t0, $t1 					# subtract two leaves and store in $t2
 	sb 		$t2, 0($sp) 					# store difference in stack
 	add 	$sp, $sp, 4 					# increment the stack position
 	add 	$t5, $t5, 1 					# switch flag on
 	j 		return 							# jump to return

###########################################################################################

 sub_swap:

 	add 	$sp, $sp, -4 					# decrement stack position
 	lb 		$t0, 0($sp) 					# load current stack value
 	add 	$t5, $t5, -1 					# turn flag off
 	j 		resume_subtract 				# jump to resume_subtract

###########################################################################################

 eval_left:

 	add 	$s1, $t8, $0 					# set new root addr to left leaf addr
 	j 		eval_loop 						# jump to eval_loop

###########################################################################################

 eval_right:

 	add 	$s1, $t9, $0 					# set new root addr to right leaf addr
 	j 		eval_loop 						# jump to eval_loop

###########################################################################################
	
 return:

 	lw 		$t7, 0($s1) 					# load addr of parent into $t7
 	beqz 	$t7, end_eval 					# if parent is null, branch to end_eval
 	add  	$s1, $t7, $0 					# set new root addr to parent addr
 	j  		eval_loop

###########################################################################################

 end_eval:

 	add 	$sp, $sp, -4 					# decrement stack position
 	lb 		$t8, 0($sp) 					# load final numerical value from stack into $t8
 	j 		end_program 						# jump to end_program

###########################################################################################

 final_traversal:

 	bnez 	$s7, done 							# if second flag is on branch to done
 	beq 	$t0, $s3, continue_traversal 		# if left leaf is equal to '+' branch to continue_traversal
 	beq 	$t0, $s4, continue_traversal 		# if left leaf is equal to '-' branch ti continue_traversal
 	j 		left_is_operand 					# else jump to left_is_operand
 continue_traversal:
 	beq 	$t1, $s3, traversal_right 			# if right leaf is equal to '+' branch to traversal_right
 	beq 	$t1, $s4, traversal_right 			# if right leaf is equal to '-' branch to traversal_right
 	beq 	$t7, $s3, final_add 					# if root operator is '+' branch to final_add
 	beq 	$t7, $s4, final_sub 					# if root operator is '-' branch to final_sub

###########################################################################################

 left_is_operand:

 	beq 	$t7, $s3, left_add 					# if root operator is '+' branch to left_add
 	beq 	$t7, $s4, left_sub 					# if root operator is '-' branch to left_sub

###########################################################################################

 left_add:

 	add 	$t0, $t0, -48 					# subtract 48 for printing purposes
 	add 	$sp, $sp, -4 					# decrement stack position
 	lb 		$t1, 0($sp) 					# load value from stack
 	add 	$t8, $t1, $t0 					# add two leaves values together and store in $t8
 	j 		end_program 				 		# jump to end_program

###########################################################################################	

 left_sub:

 	add 	$t0, $t0, -48 					# subtract 48 for printing purposes
 	add 	$sp, $sp, -4 					# decrement stack position
 	lb 		$t1, 0($sp) 					# load value from stack
 	sub 	$t8, $t0, $t1 					# subtract two leaves values and store in $t8
 	j 		end_program 						# jump to end_program

########################################################################################### 	

 traversal_right:

  	add 	$s7, $t5, $0 				# store flag from left traversal in $s7
  	add 	$t5, $0, $0 				# clear the flag
  	j 		eval_right 					# jump to eval_right

###########################################################################################

prefinal_add:

	add 	$sp, $sp, -4 				# decrement stack position
 	lb 		$t1, 0($sp) 				# load value from stack
 	add 	$t1, $t1, 48 				# add 48 to offset the subtraction later

  final_add:
 
  	sub 	$t1, $t1, 48 				# subtract 48 for printing purposes
 	add 	$sp, $sp, -4 				# decrement stack position
 	lb 		$t7, 0($sp) 				# load value from stack
 	add 	$t8, $t7, $t1 				# add final values and store sum in $t8
 	j end_program 						# jump to end_program

###########################################################################################

prefinal_sub:

	add 	$sp, $sp, -4 				# decrement stack position
 	lb 		$t1, 0($sp) 				# load value from stack
 	add 	$t1, $t1, 48 				# add 48 to offset the subtraction later

 final_sub:

 	sub 	$t1, $t1, 48 				# subtract 48 for printing purposes
 	add 	$sp, $sp, -4 				# decrement stack position
 	lb 		$t7, 0($sp) 				# load valuye from stack
 	sub 	$t8, $t7, $t1 				# subtract final values and store difference in $t8
 	j end_program 						# jump to end_program

###########################################################################################

 done:

	beq 	$t7, $s3, prefinal_add 		# if root value is '+' branch to prefinal_add
 	beq 	$t7, $s4, prefinal_sub	 	# if root value is '-' branch to prefinal_sub
 																																		#
#########################################################################################################################################
																																		#
end_program:

	li 		$v0, 4 				# opcode for print_string
	la 		$a0, newline 		# load addr for newline
	syscall

	li 		$v0, 4 				# opcode for print_string
	la 		$a0, prompt4 		# load addr for prompt4
	syscall

	li 	$v0, 1 					# opcode for print_integer
	move $a0, $t8 				# moves final numerical value into a buffer
	syscall
	
	li 		$v0, 10 			# End program
	syscall
																																		#
#########################################################################################################################################

.data

prompt: .asciiz "Expression to be evaluated:\n"
prompt2: .asciiz "Stack based Postfix: "
prompt3: .asciiz "Pre-order traversal: "
prompt4: .asciiz "Numerical result by tree traversal: "
newline: .asciiz "\n"
equals: .asciiz " = "
infix: .space 80
postfix: .space 1000 
preorderstring: .space 1000
open: .byte '('
close: .byte ')'
plus: .byte '+'
minus: .byte '-'