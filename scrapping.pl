
sub _GetBuild {
	my @build;
	my $url = "your url";
	my $data = Extract({URL => $url});

	my @ul = $data->look_down (_tag => "ul");
	my @li = $ul[1]->look_down(_tag => "li");
	foreach my $value (@li) {
		push @build, $value->as_text();
	}
	return \@build;
}

sub _GetAPIExposeMethods {
	my ($args) = @_;
	my @methodnames;
	my %methodswithparam;
	my $url = "your url";
	my $data = Extract({URL => $url});
	my @body = $data->look_down (_tag => "div", id => 'pod_body');
	foreach my $row (@body) {
		my @methodsclass = $row->look_down (_tag => "div", class => 'METHODS');
		foreach my $methodclass (@methodsclass) {
			my @methodsname = $methodclass->look_down (_tag => "dt", class => 'item-title');
			my $currentmethod;
			foreach my $methodname (@methodsname) {
				(my $method = $methodname->as_text()) =~ s/(\s*[A-Z]*$)//;
				if ($method =~ /[A-Za-z]+/) {
					$currentmethod = $method ; 
					push @methodnames, $currentmethod;
					$methodswithparam{$currentmethod} = [];
				}
				if (!$method) {
					my $param = $methodname->as_text();
					push @{$methodswithparam{$currentmethod}} , $param ;
				}
			}
		}
	}
		
	return (($args->{WITHPARAM}) ? _GetMethodInfo(): \@methodnames);
}


sub Extract {
	my ($args) = @_;
	my $url = $args->{URL};

    my $agent = WWW::Mechanize->new();
	$agent->get($url);
	my $tree = HTML::TreeBuilder->new;
	my $html = $agent->content();
	my $content = $tree->parse_content($html);
	return $tree;

}
