# MxN-cross-bar-switch
Axis based MxN cross bar switch implementation using
#### True-Round-Robin sheduling algorithm
#### Deficit-Round-Robin sheduling algorithm
<pre>
<i>Variables and Constants</i>
   const integer N             // Nb of queues
   const integer Q[1..N]       // Per queue quantum 
   integer DC[1..N]            // Per queue deficit counter
   queue queue[1..N]           // The queues   
</pre>
<pre>
<i>Scheduling Loop</i>
<b>while</b> (true)
    <b>for</b> i in 1..N       
        <b>if</b> not queue[i].empty()
            DC[i]:= DC[i] + Q[i]
            <b>while</b>( not queue[i].empty() <b>and</b>
                         DC[i] &gt;= queue[i].head().size() )
                DC[i]:= DC[i] - queue[i].head().size()
                send( queue[i].head() )
                queue[i].dequeue()
            <b>end while</b> 
            <b>if</b> queue[i].empty()
                DC[i]:= 0
            <b>end if</b>
        <b>end if</b>
    <b>end for</b>
<b>end while</b>
</pre>
