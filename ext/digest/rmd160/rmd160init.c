/* $RoughId: rmd160init.c,v 1.3 2001/07/13 20:00:43 knu Exp $ */
/* $Id$ */

#include <ruby/ruby.h>
#include "../digest.h"
#include "rmd160.h"

static const rb_digest_metadata_t rmd160 = {
    RUBY_DIGEST_API_VERSION,
    RMD160_DIGEST_LENGTH,
    RMD160_BLOCK_LENGTH,
    sizeof(RMD160_CTX),
    (rb_digest_hash_init_func_t)RMD160_Init,
    (rb_digest_hash_update_func_t)RMD160_Update,
    (rb_digest_hash_finish_func_t)RMD160_Finish,
};

/*
 * Document-class: Digest::RMD160 < Digest::Base
 * A class for calculating message digests using RIPEMD-160
 * cryptographic hash function, designed by Hans Dobbertin, Antoon
 * Bosselaers, and Bart Preneel.
 *
 * RMD160 calculates a digest of 160 bits (20 bytes).
 *
 * == Examples
 *  require 'digest'
 *
 *  # Compute a complete digest
 *  Digest::RMD160.hexdigest 'abc'      #=> "8eb208f7..."
 *
 *  # Compute digest by chunks
 *  rmd160 = Digest::RMD160.new               # =>#<Digest::RMD160>
 *  rmd160.update "ab"
 *  rmd160 << "c"                           # alias for #update
 *  rmd160.hexdigest                        # => "8eb208f7..."
 *
 *  # Use the same object to compute another digest
 *  rmd160.reset
 *  rmd160 << "message"
 *  rmd160.hexdigest                        # => "1dddbe1b..."
 */
void
Init_rmd160(void)
{
    VALUE mDigest, cDigest_Base, cDigest_RMD160;

#if 0
    mDigest = rb_define_module("Digest"); /* let rdoc know */
#endif
    mDigest = rb_digest_namespace();
    cDigest_Base = rb_const_get(mDigest, rb_intern_const("Base"));

    cDigest_RMD160 = rb_define_class_under(mDigest, "RMD160", cDigest_Base);
    rb_iv_set(cDigest_RMD160, "metadata", rb_digest_make_metadata(&rmd160));
}
