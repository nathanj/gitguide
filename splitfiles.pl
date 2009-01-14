#!/usr/bin/perl -w

my $files = ();
my $current_section = "";
my $prev_section = "";
my @toc;

my $in_header = 1;
my $in_footer = 0;

my $header = "";
my $footer = "";

open (MYFILE, 'tour.html');
while (<MYFILE>) {
	chomp;
	if ($_ =~ m/<h2 id="(.*)">(.*)<\/h2>/i) {
		$in_header = 0;
		$prev_section = $current_section;
		$current_section = $1;

		if (length($prev_section) > 0) {
			$files->{$prev_section}->{'next'} = $current_section;
		}

		$files->{$current_section}->{'prev'} = $prev_section;
		$files->{$current_section}->{'next'} = "";
		$files->{$current_section}->{'id'} = $1;
		$files->{$current_section}->{'title'} = $2;
		$files->{$current_section}->{'body'} = "$_\n";

		push(@toc, $current_section);
	} elsif ($_ =~ m/<\/body>/i) {
		$in_footer = 1;
		$footer .= "$_\n";
	} elsif ($in_header == 1) {
		$header .= "$_\n";
	} elsif ($in_footer == 1) {
		$footer .= "$_\n";
	} else {
		$files->{$current_section}->{'body'} .= "$_\n";
	}
}
close (MYFILE);

while ( my ($key, $value) = each(%$files) ) {
	open (MYFILE, ">$key.html");
	print MYFILE $header;
	print MYFILE $value->{'body'};

	my $prev = $value->{'prev'};
	my $next = $value->{'next'};
	print MYFILE "<hr />\n";
	print MYFILE "<table class=\"nav\">\n";
	print MYFILE "<tr>\n";
	print MYFILE "<td class=\"left\">\n";
	if (length($prev) > 0) {
		my $id = $files->{$prev}->{'id'};
		my $title = $files->{$prev}->{'title'};
		print MYFILE "<a id=\"back\" href=\"$id.html\">&laquo; $title</a>\n";
	}
	print MYFILE "</td>\n";
	print MYFILE "<td class=\"up\">\n";
	print MYFILE "<a id=\"up\" href=\"index.html\">Index</a>\n";
	print MYFILE "</td>\n";
	print MYFILE "<td class=\"next\">\n";
	if (length($next)) {
		my $id = $files->{$next}->{'id'};
		my $title = $files->{$next}->{'title'};
		print MYFILE "<a id=\"next\" href=\"$id.html\">$title &raquo;</a>\n";
	}
	print MYFILE "</td>\n";
	print MYFILE "</tr>\n";
	print MYFILE "</table>\n";

	print MYFILE $footer;
	close (MYFILE);
}

open (MYFILE, ">index.html");
print MYFILE $header;
print MYFILE "<h2>Table of Contents</h2>";
print MYFILE "<ol>";
foreach $page (@toc) {
	my $id = $files->{$page}->{'id'};
	my $title = $files->{$page}->{'title'};
	print MYFILE "<li><a href=\"$id.html\">$title</a></li>\n";
}
print MYFILE "</ol>";
print MYFILE "<p>This document is also available as a <a href=\"tour.html\">single page</a> (850KB of images).</p>\n";
print MYFILE $footer;

