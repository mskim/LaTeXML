# /=====================================================================\ #
# |  LaTeXML::Common::Font                                              | #
# | Representaion of Fonts                                              | #
# |=====================================================================| #
# | Part of LaTeXML:                                                    | #
# |  Public domain software, produced as part of work done by the       | #
# |  United States Government & not subject to copyright in the US.     | #
# |---------------------------------------------------------------------| #
# | Bruce Miller <bruce.miller@nist.gov>                        #_#     | #
# | http://dlmf.nist.gov/LaTeXML/                              (o o)    | #
# \=========================================================ooo==U==ooo=/ #
package LaTeXML::Common::Font;
use strict;
use warnings;
use LaTeXML::Global;
use LaTeXML::Common::Object;
use LaTeXML::Common::Dimension;
use base qw(LaTeXML::Common::Object);

# NOTE: This is now in Common that it may evolve to be useful in Post processing...

my $DEFFAMILY     = 'serif';      # [CONSTANT]
my $DEFSERIES     = 'medium';     # [CONSTANT]
my $DEFSHAPE      = 'upright';    # [CONSTANT]
my $DEFSIZE       = 'normal';     # [CONSTANT]
my $DEFCOLOR      = 'black';      # [CONSTANT]
my $DEFBACKGROUND = 'white';      # [CONSTANT]
my $DEFOPACITY    = '1';          # [CONSTANT]
my $DEFENCODING   = 'OT1';        # [CONSTANT]

#======================================================================
# Mappings from various forms of names or component names in TeX
# Given a font, we'd like to map it to the "logical" names derived from LaTeX,
# (w/ loss of fine grained control).
# I'd like to use Karl Berry's font naming scheme
# (See http://www.tug.org/fontname/html/)
# but it seems to be a one-way mapping, and moreover, doesn't even fit CM fonts!
# We'll assume a sloppier version:
#   family + series + variant + size
# NOTE: This probably doesn't really belong in here...

my %font_family = (
  cmr  => { family => 'serif' },      cmss  => { family => 'sansserif' },
  cmtt => { family => 'typewriter' }, cmvtt => { family => 'typewriter' },
  cmti => { family => 'typewriter', shape => 'italic' },
  cmfib => { family => 'serif' },      cmfr  => { family => 'serif' },
  cmdh  => { family => 'serif' },      cm    => { family => 'serif' },
  ptm   => { family => 'serif' },      ppl   => { family => 'serif' },
  pnc   => { family => 'serif' },      pbk   => { family => 'serif' },
  phv   => { family => 'sansserif' },  pag   => { family => 'serif' },
  pcr   => { family => 'typewriter' }, pzc   => { family => 'script' },
  put   => { family => 'serif' },      bch   => { family => 'serif' },
  psy   => { family => 'symbol' },     pzd   => { family => 'dingbats' },
  ccr   => { family => 'serif' },      ccy   => { family => 'symbol' },
  cmbr  => { family => 'sansserif' },  cmtl  => { family => 'typewriter' },
  cmbrs => { family => 'symbol' },     ul9   => { family => 'typewriter' },
  txr   => { family => 'serif' },      txss  => { family => 'sansserif' },
  txtt  => { family => 'typewriter' }, txms  => { family => 'symbol' },
  txsya => { family => 'symbol' },     txsyb => { family => 'symbol' },
  pxr   => { family => 'serif' },      pxms  => { family => 'symbol' },
  pxsya => { family => 'symbol' },     pxsyb => { family => 'symbol' },
  futs  => { family => 'serif' },
  uaq   => { family => 'serif' },      ugq   => { family => 'sansserif' },
  eur   => { family => 'serif' },      eus   => { family => 'script' },
  euf   => { family => 'fraktur' },    euex  => { family => 'symbol' },
  # The following are actually math fonts.
  ms    => { family => 'symbol' },
  ccm   => { family => 'serif', shape => 'italic' },
  cmm   => { family => 'italic', encoding => 'OML' },
  cmex  => { family => 'symbol', encoding => 'OMX' },       # Not really symbol, but...
  cmsy  => { family => 'symbol', encoding => 'OMS' },
  ccitt => { family => 'typewriter', shape => 'italic' },
  cmbrm => { family => 'sansserif', shape => 'italic' },
  futm  => { family => 'serif', shape => 'italic' },
  futmi => { family => 'serif', shape => 'italic' },
  txmi  => { family => 'serif', shape => 'italic' },
  pxmi  => { family => 'serif', shape => 'italic' },
  bbm   => { family => 'blackboard' },
  bbold => { family => 'blackboard' },
  bbmss => { family => 'blackboard' },
  # some ams fonts
  cmmib => { family => 'italic', series   => 'bold' },
  cmbsy => { family => 'symbol', series   => 'bold' },
  msa   => { family => 'symbol', encoding => 'AMSA' },
  msb   => { family => 'symbol', encoding => 'AMSB' },
  # Are these really the same?
  msx => { family => 'symbol', encoding => 'AMSA' },
  msy => { family => 'symbol', encoding => 'AMSB' },
);

# Maps the "series code" to an abstract font series name
my %font_series = (
  '' => { series => 'medium' }, m   => { series => 'medium' }, mc => { series => 'medium' },
  b  => { series => 'bold' },   bc  => { series => 'bold' },   bx => { series => 'bold' },
  sb => { series => 'bold' },   sbc => { series => 'bold' },   bm => { series => 'bold' });

# Maps the "shape code" to an abstract font shape name.
my %font_shape = ('' => { shape => 'upright' }, n => { shape => 'upright' }, i => { shape => 'italic' }, it => { shape => 'italic' },
  sl => { shape => 'slanted' }, sc => { shape => 'smallcaps' }, csc => { shape => 'smallcaps' });

# These could be exported...
sub lookupFontFamily {
  my ($familycode) = @_;
  return $font_family{ ToString($familycode) }; }

sub lookupFontSeries {
  my ($seriescode) = @_;
  return $font_series{ ToString($seriescode) }; }

sub lookupFontShape {
  my ($shapecode) = @_;
  return $font_shape{ ToString($shapecode) }; }

# Decode a font size in points into a "logical" size.
# associate a logical size with all pt sizes (/10) below the given number.
my @font_size_map = (0.60 => 'tiny', 0.75 => 'script', 0.85 => 'footnote', 0.95 => 'small',
  1.10 => 'normal', 1.30 => 'large', 1.55 => 'Large', 1.85 => 'LARGE',
  2.25 => 'huge', 1000.0 => 'Huge');
# abstract font size in pts.
my %font_size = (
  tiny   => 5,  script => 7,  footnote => 8,  small => 9,
  normal => 10, large  => 12, Large    => 14, LARGE => 17,
  huge   => 20, Huge   => 25);

sub lookupFontSize {
  my ($size) = @_;
  if (defined $size) {
    my $scaled = $size / 10.0;     # ASSUMED nominal font 10pt!!! Set from doc!!!
    my @map    = @font_size_map;
    while (@map) {
      return shift(@map) if ($scaled <= shift(@map));
      shift(@map); }
    return 'Huge'; }
  else {
    return 'normal'; } }

my $FONTREGEXP
  = '(' . join('|', sort { -($a cmp $b) } keys %font_family) . ')'
  . '(' . join('|', sort { -($a cmp $b) } keys %font_series) . ')'
  . '(' . join('|', sort { -($a cmp $b) } keys %font_shape) . ')'
  . '(\d*)';

sub decodeFontname {
  my ($name, $at, $scaled) = @_;
  if ($name =~ /^$FONTREGEXP$/o) {
    my %props;
    my ($fam, $ser, $shp, $size) = ($1, $2, $3, $4);
    if (my $ffam = lookupFontFamily($fam)) { map { $props{$_} = $$ffam{$_} } keys %$ffam; }
    if (my $fser = lookupFontSeries($ser)) { map { $props{$_} = $$fser{$_} } keys %$fser; }
    if (my $fsh  = lookupFontShape($shp))  { map { $props{$_} = $$fsh{$_} } keys %$fsh; }
    $size = 1 unless defined $size;
    $size = $at if defined $at;
    $size *= $scaled if defined $scaled;
    $props{size} = lookupFontSize($size);
    # Experimental Hack !?!?!?
    $props{encoding} = 'OT1' unless defined $props{encoding};
    return %props; }
  else {
    return; } }

sub lookupTeXFont {
  my ($fontname, $seriescode, $shapecode) = @_;
  my %props;
  if (my $ffam = lookupFontFamily($fontname)) {
    map { $props{$_} = $$ffam{$_} } keys %$ffam; }
  if (my $fser = lookupFontSeries($seriescode)) {
    map { $props{$_} = $$fser{$_} } keys %$fser; }
  if (my $fsh = lookupFontShape($shapecode)) {
    map { $props{$_} = $$fsh{$_} } keys %$fsh; }
  return %props; }

#======================================================================
# NOTE:  Would it make sense to allow compnents to be `inherit' ??

# Note: forcebold, forceshape are only useful for fonts in math
sub new {
  my ($class, %options) = @_;
  my $family     = $options{family};
  my $series     = $options{series};
  my $shape      = $options{shape};
  my $size       = $options{size};
  my $color      = $options{color};
  my $bg         = $options{background};
  my $opacity    = $options{opacity};
  my $encoding   = $options{encoding};
  my $forcebold  = $options{forcebold};
  my $forceshape = $options{forceshape};
  return $class->new_internal(
    $family, $series, $shape, $size,
    $color, $bg, $opacity,
    $encoding, $forcebold, $forceshape); }

sub new_internal {
  my ($class, @components) = @_;
  return bless [@components], $class; }

sub textDefault {
  my ($self) = @_;
  return $self->new_internal($DEFFAMILY, $DEFSERIES, $DEFSHAPE, $DEFSIZE,
    $DEFCOLOR, $DEFBACKGROUND, $DEFOPACITY, $DEFENCODING, undef, undef); }

sub mathDefault {
  my ($self) = @_;
  return $self->new_internal('math', $DEFSERIES, 'italic', $DEFSIZE,
    $DEFCOLOR, $DEFBACKGROUND, $DEFOPACITY, undef, undef, undef); }

# Accessors
sub getFamily     { my ($self) = @_; return $$self[0]; }
sub getSeries     { my ($self) = @_; return $$self[1]; }
sub getShape      { my ($self) = @_; return $$self[2]; }
sub getSize       { my ($self) = @_; return $$self[3]; }
sub getColor      { my ($self) = @_; return $$self[4]; }
sub getBackground { my ($self) = @_; return $$self[5]; }
sub getOpacity    { my ($self) = @_; return $$self[6]; }
sub getEncoding   { my ($self) = @_; return $$self[7]; }

sub toString {
  my ($self) = @_;
  return "Font[" . join(',', map { (defined $_ ? $_ : '*') } @{$self}) . "]"; }

sub stringify {
  my ($self) = @_;
  return $self->toString; }

sub equals {
  my ($self, $other) = @_;
  return (defined $other) && ((ref $self) eq (ref $other))
    && (join('|', map { (defined $_ ? $_ : '*') } @$self)
    eq join('|', map { (defined $_ ? $_ : '*') } @$other)); }

sub match {
  my ($self, $other) = @_;
  return 1 unless defined $other;
  return 0 unless (ref $self) eq (ref $other);
  my @comp  = @$self;
  my @ocomp = @$other;
  # If any components are defined in both fonts, they must be equal.
  while (@comp) {
    my $c  = shift @comp;
    my $oc = shift @ocomp;
    return 0 if (defined $c) && (defined $oc) && ($c ne $oc); }
  return 1; }

sub makeConcrete {
  my ($self, $concrete) = @_;
  my ($family,  $series,  $shape,  $size,  $color,  $bg,  $opacity,  $encoding)  = @$self;
  my ($ofamily, $oseries, $oshape, $osize, $ocolor, $obg, $oopacity, $oencoding) = @$concrete;
  return (ref $self)->new_internal(
    $family || $ofamily, $series || $oseries, $shape || $oshape, $size || $osize,
    $color || $ocolor, $bg || $obg, (defined $opacity ? $opacity : $oopacity),
    $encoding || $oencoding); }

sub isDiff {
  my ($x, $y) = @_;
  return (defined $x) && (!(defined $y) || ($x ne $y)); }

# Return a hash of the differences in font, size and color
# [does encoding play a role here?]
# Note that this returns a hash of Fontable.attributes & Colorable.attributes,
# NOT the font keywords!!!
sub relativeTo {
  my ($self, $other) = @_;
  my ($fam,  $ser,  $shp,  $siz,  $col,  $bkg,  $opa,  $enc)  = @$self;
  my ($ofam, $oser, $oshp, $osiz, $ocol, $obkg, $oopa, $oenc) = @$other;
  $fam  = 'serif' if $fam  && ($fam eq 'math');
  $ofam = 'serif' if $ofam && ($ofam eq 'math');
  my @diffs = (
    (isDiff($fam, $ofam) ? ($fam) : ()),
    (isDiff($ser, $oser) ? ($ser) : ()),
    (isDiff($shp, $oshp) ? ($shp) : ()));
  return (
    (@diffs ? (font => join(' ', @diffs)) : ()),
    (isDiff($siz, $osiz) ? (fontsize        => $siz) : ()),
    (isDiff($col, $ocol) ? (color           => $col) : ()),
    (isDiff($bkg, $obkg) ? (backgroundcolor => $bkg) : ()),
    (isDiff($opa, $oopa) ? (opacity         => $opa) : ()),
    ); }

sub distance {
  my ($self, $other) = @_;
  my ($fam,  $ser,  $shp,  $siz,  $col,  $bkg,  $opa,  $enc)  = @$self;
  my ($ofam, $oser, $oshp, $osiz, $ocol, $obkg, $oopa, $oenc) = @$other;
  $fam  = 'serif' if $fam  && ($fam eq 'math');
  $ofam = 'serif' if $ofam && ($ofam eq 'math');
  return
    (isDiff($fam, $ofam) ? 1 : 0)
    + (isDiff($ser, $oser) ? 1 : 0)
    + (isDiff($shp, $oshp) ? 1 : 0)
    + (isDiff($siz, $osiz) ? 1 : 0)
    + (isDiff($col, $ocol) ? 1 : 0)
    + (isDiff($bkg, $obkg) ? 1 : 0)
    + (isDiff($opa, $oopa) ? 1 : 0)
##  + (isDiff($enc,$oenc)  ? 1 : 0)
    ; }

# This matches fonts when both are converted to strings (toString),
# such as when they are set as attributes.
# This accumulates regular expressions used by match_font
# (which, in turn, is used in various XPath searches!)
# It is NOT really Daemon safe....
# Need to work out how to do this and/or cache it in STATE????
our %FONT_REGEXP_CACHE = ();

sub match_font {
  my ($font1, $font2) = @_;
  my $regexp = $FONT_REGEXP_CACHE{$font1};
  if (!$regexp) {
    if ($font1 =~ /^Font\[(.*)\]$/) {
      my @comp = split(',', $1);
      my $re = '^Font\['
        . join(',', map { ($_ eq '*' ? "[^,]+" : "\Q$_\E") } @comp)
        . '\]$';
      print STDERR "\nCreating re for \"$font1\" => $re\n";
      $regexp = $FONT_REGEXP_CACHE{$font1} = qr/$re/; } }
  return $font2 =~ /$regexp/; }

sub font_match_xpaths {
  my ($font) = @_;
  if ($font =~ /^Font\[(.*)\]$/) {
    my @comps = split(',', $1);
    my ($frag, @frags) = ();
    for (my $i = 0 ; $i <= $#comps ; $i++) {
      my $comp = $comps[$i];
      if ($comp eq '*') {
        push(@frags, $frag) if $frag;
        $frag = undef; }
      else {
        my $post = ($i == $#comps ? ']' : ',');
        if ($frag) {
          $frag .= $comp . $post; }
        else {
          $frag = ($i == 0 ? 'Font[' : ',') . $comp . $post; } } }
    push(@frags, $frag) if $frag;
    return join(' and ', '@_font',
      map { "contains(\@_font,'$_')" } @frags); } }

# # Presumably a text font is "sticky", if used in math?
# sub isSticky { return 1; }

#======================================================================
sub computeStringSize {
  my ($self, $string) = @_;
  my $size = $self->getSize;
  my $u    = (defined $string
    ? ($font_size{ $self->getSize || $DEFSIZE } || 10) * 65535 * length($string)
    : 0);
  return (Dimension(0.75 * $u), Dimension(0.7 * $u), Dimension(0.2 * $u)); }

# Get nominal width, height base ?
sub getNominalSize {
  my ($self) = @_;
  my $size = $self->getSize;
  my $u = ($font_size{ $self->getSize || $DEFSIZE } || 10) * 65535;
  return (Dimension(0.75 * $u), Dimension(0.7 * $u), Dimension(0.2 * $u)); }

# sub default {
#   my ($self) = @_;
#   return $self->new_internal('math', $MDEFSERIES, 'italic', $MDEFSIZE,
#     $MDEFCOLOR, $MDEFBACKGROUND, $MDEFOPACITY,
#     undef, undef, undef); }

sub isSticky {
  my ($self) = @_;
  return $$self[0] && ($$self[0] =~ /^(?:serif|sansserif|typewriter)$/); }

# NOTE: In math, NORMALLY, setting any one of
#    family, series or shape
# will, usually, automatically reset the others to thier defaults!
# You must arrange this in the calls....
sub merge {
  my ($self, %options) = @_;
  my $family     = $options{family}     // $$self[0];
  my $series     = $options{series}     // $$self[1];
  my $shape      = $options{shape}      // $$self[2];
  my $size       = $options{size}       // $$self[3];
  my $color      = $options{color}      // $$self[4];
  my $bg         = $options{background} // $$self[5];
  my $opacity    = $options{opacity}    // $$self[6];
  my $encoding   = $options{encoding}   // $$self[7];
  my $forcebold  = $options{forcebold}  // $$self[8];
  my $forceshape = $options{forceshape} // $$self[9];
  return (ref $self)->new_internal($family, $series, $shape, $size,
    $color,    $bg,        $opacity,
    $encoding, $forcebold, $forceshape); }

# Instanciate the font for a particular class of symbols.
# NOTE: This works in `normal' latex, but probably needs some tunability.
# Depending on the fonts being used, the allowable combinations may be different.
# Getting the font right is important, since the author probably
# thinks of the identity of the symbols according to what they SEE in the printed
# document.  Even though the markup might seem to indicate something else...

# Use Unicode properties to determine font merging.
sub specialize {
  my ($self, $string) = @_;
  return $self unless defined $string;
  my ($family, $series, $shape, $size, $color, $bg, $opacity,
    $encoding, $forcebold, $forceshape) = @$self;
  $series = 'bold' if $forcebold;
  if (($string =~ /^\p{Latin}$/) && ($string =~ /^\p{L}$/)) {    # Latin Letter
    $shape = 'italic' if !$shape && !$family; }
  elsif ($string =~ /^\p{Greek}$/) {                             # Single Greek character?
    if ($string =~ /^\p{Lu}$/) {                                 # Uppercase
      if (!$family || ($family eq 'math')) {
        $family = $DEFFAMILY;
        $shape = $DEFSHAPE if $shape && ($shape ne $DEFSHAPE); } }    # if ANY shape, must be default
    else {    # Lowercase
      $family = $DEFFAMILY if !$family || ($family ne $DEFFAMILY);
      $shape  = 'italic'   if !$shape  || !$forceshape;              # always ?
      if ($forcebold) { $series = 'bold'; }
      elsif ($series && ($series ne $DEFSERIES)) { $series = $DEFSERIES; } } }
  elsif ($string =~ /^\p{N}$/) {                                     # Digit
    if (!$family || ($family eq 'math')) {
      $family = $DEFFAMILY;
      $shape  = $DEFSHAPE; } }                                       # defaults, always.
  else {                                                             # Other Symbol
    $family = $DEFFAMILY;
    $shape  = $DEFSHAPE;                                             # defaults, always.
    if ($forcebold) { $series = 'bold'; }
    elsif ($series && ($series ne $DEFSERIES)) { $series = $DEFSERIES; } }

  return (ref $self)->new_internal($family, $series, $shape, $size,
    $color,    $bg,        $opacity,
    $encoding, $forcebold, $forceshape); }

#**********************************************************************
1;

__END__

=pod 

=head1 NAME

C<LaTeXML::Common::Font> - representation of fonts

=head1 DESCRIPTION

C<LaTeXML::Common::Font> represent fonts in LaTeXML.
It extends L<LaTeXML::Common::Object>.

This module defines Font objects.
I'm not completely happy with the arrangement, or
maybe just the use of it, so I'm not going to document extensively at this point.

The attributes are

 family : serif, sansserif, typewriter, caligraphic,
          fraktur, script
 series : medium, bold
 shape  : upright, italic, slanted, smallcaps
 size   : tiny, footnote, small, normal, large,
          Large, LARGE, huge, Huge
 color  : any named color, default is black

They are usually merged against the current font, attempting to mimic the,
sometimes counter-intuitive, way that TeX does it,  particularly for math

=head1 Methods

=over 4

=item  C<< $font->specialize($string); >>

In math mode, C<LaTeXML::Common::Font> supports computing a font reflecting
how the specific C<$string> would be printed when
C<$font> is active; This (attempts to) handle the curious ways that lower case
greek often doesn't get a different font.  In particular, it recognizes the
following classes of strings: single latin letter, single uppercase greek character,
single lowercase greek character, digits, and others.

=back

=head1 AUTHOR

Bruce Miller <bruce.miller@nist.gov>

=head1 COPYRIGHT

Public domain software, produced as part of work done by the
United States Government & not subject to copyright in the US.

=cut
