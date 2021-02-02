require 'json'



############
##  Поля  ##
############
@SDM_DANGER_BUILD_FILES = ['Podfile']
@SDM_DANGER_BIG_PR_LINES = 1000
@HAS_FAIL_CONDITIONS = false
ACTIVE_FILES = (git.modified_files + git.added_files).uniq
MR_DIFF_RESTRICTION = 600


 ###############
 ##  Методы  ##
###############

def didModify(files_array)
	did_modify_files = false
	files_array.each do |filename|
		if git.modified_files.include?(filename) || git.deleted_files.include?(filename)
			did_modify_files = true
		end
	end
	return did_modify_files
end

def failWithReason(reason)
    if @IS_DANGER_DISABLED
        warn(reason)
    else
        fail(reason, sticky: true)
        @HAS_FAIL_CONDITIONS = true
    end
end

def checkSwiftFilesForBanStrings
    swift_files = ACTIVE_FILES.select { |file| file.end_with? '.swift' }

    swift_files_has_banned_strings = false

    swift_files.each do | filename |
        #todo swift добавить проверку по строкам, не проверять НЕ modified)
        lines = git.diff_for_file(filename)
        lines.each do | l |
            AVOID_STRINGS_MAP.each do |avoid|
                line = lines.index line
                if l.include? avoid[:word]
                    warn(avoid[:reason])
                    swift_files_has_banned_strings = true
                end
              end
        end
    end
    
    if !swift_files_has_banned_strings then
        message 'Запрещённые конструкции отсутствуют'
    end
end

#############
 ##  Блок валидации  ##
######################

if @IS_DANGER_DISABLED
    warn('ВНИМАНИЕ! Danger работает в ограниченном режиме, безопасность кодовой базы под угрозой.')
end

if didModify(@SDM_DANGER_BUILD_FILES)
    failWithReason('Был изменен Podfile')
else
    message('Podfile в порядке')
end

# checkSwiftFilesForBanStrings()

def countPdfLines()
    pdf_l=0
 
    ACTIVE_FILES.select { |file| file.end_with? ".pdf" }
        .each do | file |
            pdf_l +=git.diff_for_file("#{file}").patch.lines.length
        end
    return pdf_l
end

pdf_l = countPdfLines()

if (git.lines_of_code-git.deletions) > (MR_DIFF_RESTRICTION + pdf_l) then 
    failWithReason('Слишком большой MR') 
else
    message("Изменено, #{git.lines_of_code}, Удалено строк, #{git.deletions}")

    message("Оптимальный размер MR не превышает установленный, #{MR_DIFF_RESTRICTION}",
             "Не учитывая PDF   :   #{pdf_l}",
             "Не учитывая удаления  :    #{git.deletions}")
end

  #######################
  ##  Generate report  ##
  #######################

xcov.report(
   scheme: 'MVVM-C',
   workspace: 'MVVM-C.xcworkspace',
   minimum_coverage_percentage: 50.0
)

report = xcov.produce_report(
    scheme: 'MVVM-C',
    workspace: 'MVVM-C.xcworkspace',
    minimum_coverage_percentage: 30.0
  )

  xcov.output_report(report)

at_exit {

    if @HAS_FAIL_CONDITIONS then
        raise('Есть ошибки валидации, завершаемся с падением')
    else
        message('Удачного Core Review')
    end
}



