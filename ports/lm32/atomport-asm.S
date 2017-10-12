/*
 * Copyright (c) 2017, Mikeqin. All rights reserved.
 * Copyright (c) 2017, xuzhenxing. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. No personal names or organizations' names associated with the
 *    Atomthreads project may be used to endorse or promote products
 *    derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE ATOMTHREADS PROJECT AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
 * TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE PROJECT OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

#include "atomport-asm-macros.h"

.section .text

/**
 * @brief Return threads switch 
 * Exit critical area and Enable interrupt 
 * Return func call
 */
.globl contextExitCritical
contextExitCritical:
	/* Enalbe interrupt return func call */
	ori r1, r1, 0x7
	wcsr IE, r1
	ret

/**
 * @brief Enter threads switch
 * Enter critical area and Disable interrupt
 * Return func all
 */
.globl contextEnterCritical
contextEnterCritical:
    	/* Disable interrupt, direct to writing r0 to IE */
    	wcsr IE, r0
    	ret

/**
 * Function that performs the contextSwitch. Whether its a voluntary release
 * of CPU by thread or a pre-emption, under both conditions this function is
 * called. The signature is as follows:
 *
 * archContextSwitch(ATOM_TCB *old_tcb, ATOM_TCB *new_tcb)
 */
.globl archContextSwitch
archContextSwitch:
    	/* R1 is argument0, save old_tcb when we return from here */
	lw r25, (r1+0)

	SAVE_REG(r25, fp)
	SAVE_REG(r25, sp)
	SAVE_REG(r25, ra)

    	/* R2 is argument1, load new_tcb data to memory */
	lw r25, (r2+0)
   
	LOAD_REG(r25, fp)
	LOAD_REG(r25, sp)
	LOAD_REG(r25, ra)

	lw r1, (r25+(r1_IDX * 4))

   	/* Enable global interrupts */
	ori r2, r2, 0x7
	wcsr IE, r2

   	/* Return call function */
   	ret

/**
 * archFirstThreadRestore(ATOM_TCB *new_tcb)
 *
 * This function is responsible for restoring and starting the first
 * thread the OS runs. It expects to find the thread context exactly
 * as it would be if a context save had previously taken place on it.
 * The only real difference between this and the archContextSwitch()
 * routine is that there is no previous thread for which context must
 * be saved.
 *
 * The final action this function must do is to restore interrupts.
 */
.globl archFirstThreadRestore
archFirstThreadRestore:
    	/* R1 is argument0, load first thread */
	lw r25, (r1+0)

	LOAD_REG(r25, fp)
	LOAD_REG(r25, sp)
	LOAD_REG(r25, ra)

	lw r1, (r25+(r1_IDX * 4))

    	/* Enable global interrupts */
	ori r2, r2, 0x7
	wcsr IE, r2

    	/* Return call function */
    	ret
