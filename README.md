# X12SqlServer
Simple X12 data model with TSQL parsing procedures

The purpose of this solution is to give SQL developers the ability to easily manipulate and/or query data in X12 format.

usp_Batch_Create: Main entry point for the application.  Given some X12 input, this will create a single new batch which will
act as the parent for all subordinate segments.  All the segment data will be parsed into the Segment table. It then determines 
which version of X12 was sent and picks the applicable parsing procedure which assigns an envelope id to each segment.

usp_Batch_ExtractAsX12: This pulls all the data from the Segment table given its parent batch id.  It concatonates everything
back into an X12 string.

usp_Envelope_Hierarchy: This procedure gives a user friendly view of how envelopes (loops) are organized in a transaction.
The output from this proc can be loaded to a temp table and joined to the segment table if desired.

usp_Test: This procedure was designed to test parsing logic.  The idea is to pass in a string of X12, shred it into the data
model, then pull it back into an X12 string.  For the test to pass the input and output should match and all segments should
have an envelope assigned.  There is an issue when using new line characters, that the very last segment will not have them.
For this reason trim them from the input parameter before passing to this routine.