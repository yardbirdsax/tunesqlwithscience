## Tuning SQL Server Performance With Science!?

<image src="https://media.giphy.com/media/g2Z1gVqDAILGo/giphy.gif" />

---

### Who am I?

<img style="width:30%" src="images/josh.jpg" />

<div style="font-size:18px">

* Manager of Technology Operations for Gateway Ticketing
* Former SQL Server DBA and Database Developer / Architect

LinkedIn: https://linkedin.com/in/joshuafeierman

GitHub: https://github.com/yardbirdsax

</div>

---

## Goals

* How to fail at tuning SQL Server queries
* What's the scientific method?
* Applying it in 5 steps
* Examples

---

## How to fail

<ul>
<li class="fragment">Don't collect data, such as CPU usage, IO statistics, etc</li>
<li class="fragment">Assume the first thing you think of is the cause of the problem</li>
<li class="fragment">Don't attempt to reproduce the issue outside the environment where it's happening</li>
<li class="fragment">Don't test that the "fix" actually fixes the problem, as opposed to the placebo effect</li>
</ul>
----

## Examples

* "We upgraded the instance to Enterprise Edition, and now it's faster, so Enterprise Edition needs to be installed everywhere."

----

## Examples

* "We rebooted SQL Server and now it's running fine, so we need to reboot right before we run this every time."

----

## Examples

* "We never have good data outside the live environment, so there's no point in trying to reproduce this. We need to be able to change code in production on the fly until it's fixed."

----

## Examples

* "After we applied the change the query ran faster so it must have fixed the problem."

----

<div style="width:100%;height:0;padding-bottom:56%;position:relative;"><iframe src="https://giphy.com/embed/11tTNkNy1SdXGg" width="100%" height="100%" style="position:absolute" frameBorder="0" class="giphy-embed" allowFullScreen></iframe></div><p><a href="https://giphy.com/gifs/disneypixar-disney-pixar-11tTNkNy1SdXGg">via GIPHY</a></p>

---

## How science can help us

<img src="images/scientist.jpg" style="width:40%; align:center" />

<span style="font-size:12px">Photo by Hush Naidoo on Unsplash</span>

---

## The scientific method

<div style="font-size:30px">

1. Define a question. What problem are we trying to solve?
1. Gather information (observations).
1. Form an exploratory hypothesis. What explains what we are seeing?
1. Test the hypothesis by performing and experiment and collecting data.
1. Analyze the data.
1. Draw a conclusion: Does the data support our previous hypothesis, or should we create a new one based on the data?
1. Publish the results of the experiment.
1. Retest (frequently done by other scientists).

</div>
---

## The scientific method (applied to SQL) in 5 steps

----

## The scientific method (applied to SQL) in 5 steps

1. Define a problem.
1. Gather data and observations.
1. Analyze the data and form a hypothesis.
1. Test the hypothesis by performing an experiment and collecting data in a reproducible manner.
1. Analyze your results and decide if the solution works.

---

### Define a problem

----

### Example

BAD: "The system runs slowly."

NOTES: 1. It's not specific. 2. It doesn't include how to produce the problem.

----

### Example

GOOD: "When users run the TPS report for the Alameda Corp client, the report times out after 30 seconds and isn't displayed."

NOTES: 1. It describes the specific behavior we need to investigate. 2. It contains the actual steps to reproduce the problem. 3. It describes how we'll know if the problem is resolved.

---

## Gather data and observations

----

### Gather data and observations

* CPU usage
* Disk IO performance (hint: sequential reads for reports, random reads / writes for transactional, except for transaction log volumes)
* Execution plans (Actual ones, not estimated)
* SQL Server statistics (hint: sampled is often not adequate)

----

### Example

* The actual query plan shows a large discrepancy between the actual and estimated row counts of certain operations.
* The report only times out when run for a particular client, except when that client is the first report run for the day.

----

### Tools to use

* PerfMon
* Glenn Berry's Diagnostic Queries
* Extended Events
* SentryOne Plan Explorer (we'll use this one later)

---

## Form a hypothesis

----

>"A proposition, or set of propositions, set forth as an explanation for the occurance of some specified group of phenomena, either asserted merely as a provisional conjecture to guide investigation (working hypothesis) or accepted as highly probably in light of established facts."

----

>"Why are we seeing what we're seeing?"

----

### Example

"The report is timing out because SQL Server expects the nested loop join between tables 'A' and 'B' to only execute on 30 rows, when in fact the previous operation results in over 1,000,000 rows. This is because the particular parameters supplied for the query result in a very different set of data than is typical for other parameter values."

---

## Test the hypothesis

----

<span style="font-size:28px">
Me: "So, how do you know that that particular JOIN in the query is the cause of the problem?"

Them: "Because we changed it and it went faster."

Me: "Ok, how do you know that the change you made actually made it faster? If you undo your change, is it back to being slow? Did you look at the query statistics to see if the table used in the JOIN had a lot of logical IO against it?"

Them: "Well, what else could it be? We didn’t try rolling back the change, since it worked so well. Why waste time doing that?"

Me: "OK, good luck with that. I’m opening a boutique…"
</span>

----

### Characteristics of a good experiment

<ul>
<li class="fragment">Always start from the same state.</li>
<li class="fragment">Must include a negative condition.</li>
</ul>

----

### Example

<ul style="font-size:24px">
<li class="fragment">Clear the plan and buffer caches.</li>
<li class="fragment">Run the stored procedure specifying another client, then the problem client, and confirm that statistics collected match the problem condition.</li>
<li class="fragment">Clear the plan and buffer caches.</li>
<li class="fragment">Apply a change to the procedure.</li>
<li class="fragment">Run the stored procedure specifying another client, then the problem client, and confirm that statistics collected have improved.</li>
<li class="fragment">Clear the plan and buffer caches.</li>
<li class="fragment">Reverse the change to the procedure.</li>
<li class="fragment">Run the stored procedure specifying another client, then the problem client, and confirm that statistics have reverted to their previous levels.</li>
</ul>

---

## Analyze the results

<ul style="font-size:30px">
<li class="fragment">Does the solution solve the problem?</li>
<li class="fragment">If yes, how can we continue to collect data to ensure we're right after we've deployed the fix?</li>
<li class="fragment">If no, go back to step 3 and start again.</li>
</ul>

---

## Questions?

<div style="width:50%;height:0;padding-bottom:75%;position:relative;"><iframe src="https://giphy.com/embed/yfEjNtvqFBfTa" width="100%" height="100%" style="position:absolute" frameBorder="0" class="giphy-embed" allowFullScreen></iframe></div><p><a href="https://giphy.com/gifs/epilepsy-warning-muppets-yfEjNtvqFBfTa">via GIPHY</a></p>