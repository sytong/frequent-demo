# 
# Originally written by @buruzaemon
#
module Homer
 
  # regexp pattern for filtering words in Homerian text
  PATT = /
  '(s|m|d|ll|re|ve) # - remove contractions
| [[:punct:]]       # - remove remaining punctuation
/x
 
  # after filtering tokens out of text using PATT
  # remove all stopwords below
  STOPWORDS = %w(
    a  able  about  across  after  all  almost  also  am  among  an
    and any  are  as  at  be  because  been  but  by can
    cannot  could  dear did  do  does  either  else  ever  every
    for  from  get  got  had  has have  he  her  hers  him
    his  how  however  i  if  in  into  is  it  its just
    least  let  like  likely  may  me  might  most  must  my  neither
    no  nor  not  o  of  off  often  on  only  or  other  our
    own  rather  said say  says  she  should  since  so  some  than
    that  the  their  them then  there  these  they  this  tis  to
    too  twas  us  wants  was  we  were  what  when  where  which
    while  who  whom  why  will  with  would  yet  you  your end
  )
 
 
  def self.enumerate
    Enumerator.new do |y|
      begin
        File.foreach(File.join(File.dirname(__FILE__), "../data/iliad_odyssey.clean.txt"), 'rb') do |line|
          toks = line.strip.gsub(PATT, '').split
          toks.each do |token|
            y.yield token if !STOPWORDS.include? token.downcase
          end
        end
      rescue
        $stderr.puts("ERROR: #{$!}")
        $@.each do |err|
          $stderr.puts("  #{err}")
        end
      end
    end
  end
end