#include <sys/user.h>
#include <sys/sysctl.h>
#include <sys/param.h>
#include <libprocstat.h>
# ifndef KVME_TYPE_MGTDEVICE
# define KVME_TYPE_MGTDEVICE     8
# endif
void
procstat_vm(struct procstat *procstat, struct kinfo_proc *kipp, FILE *errout)
{
	struct kinfo_vmentry *freep, *kve;
	int ptrwidth;
	unsigned int i, cnt;
	const char *str;
#ifdef __x86_64__
	ptrwidth = 14;
#else
	ptrwidth = 2*sizeof(void *) + 2;
#endif
	fprintf(errout, "%*s %*s %3s %4s %4s %3s %3s %4s %-2s %-s\n",
		ptrwidth, "START", ptrwidth, "END", "PRT", "RES",
		"P""RES", "REF", "SHD", "FL", "TP", "PATH");

#ifdef HAVE_PROCSTAT_GETVMMAP
	freep = procstat_getvmmap(procstat, kipp, &cnt);
#else
	freep = kinfo_getvmmap(kipp->ki_pid, &cnt);
#endif
	if (freep == NULL)
		return;
	for (i = 0; i < cnt; i++) {
		kve = &freep[i];
		fprintf(errout, "%#*jx ", ptrwidth, (uintmax_t)kve->kve_start);
		fprintf(errout, "%#*jx ", ptrwidth, (uintmax_t)kve->kve_end);
		fprintf(errout, "%s", kve->kve_protection & KVME_PROT_READ ? "r" : "-");
		fprintf(errout, "%s", kve->kve_protection & KVME_PROT_WRITE ? "w" : "-");
		fprintf(errout, "%s ", kve->kve_protection & KVME_PROT_EXEC ? "x" : "-");
		fprintf(errout, "%4d ", kve->kve_resident);
		fprintf(errout, "%4d ", kve->kve_private_resident);
		fprintf(errout, "%3d ", kve->kve_ref_count);
		fprintf(errout, "%3d ", kve->kve_shadow_count);
		fprintf(errout, "%-1s", kve->kve_flags & KVME_FLAG_COW ? "C" : "-");
		fprintf(errout, "%-1s", kve->kve_flags & KVME_FLAG_NEEDS_COPY ? "N" :
		    "-");
		fprintf(errout, "%-1s", kve->kve_flags & KVME_FLAG_SUPER ? "S" : "-");
		fprintf(errout, "%-1s ", kve->kve_flags & KVME_FLAG_GROWS_UP ? "U" :
		    kve->kve_flags & KVME_FLAG_GROWS_DOWN ? "D" : "-");
		switch (kve->kve_type) {
		case KVME_TYPE_NONE:
			str = "--";
			break;
		case KVME_TYPE_DEFAULT:
			str = "df";
			break;
		case KVME_TYPE_VNODE:
			str = "vn";
			break;
		case KVME_TYPE_SWAP:
			str = "sw";
			break;
		case KVME_TYPE_DEVICE:
			str = "dv";
			break;
		case KVME_TYPE_PHYS:
			str = "ph";
			break;
		case KVME_TYPE_DEAD:
			str = "dd";
			break;
		case KVME_TYPE_SG:
			str = "sg";
			break;
		case KVME_TYPE_MGTDEVICE:
			str = "md";
			break;
		case KVME_TYPE_UNKNOWN:
		default:
			str = "??";
			break;
		}
		fprintf(errout, "%-2s ", str);
		fprintf(errout, "%-s\n", kve->kve_path);
	}
	free(freep);
}
